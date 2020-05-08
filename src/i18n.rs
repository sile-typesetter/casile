use fluent::{FluentArgs, FluentBundle, FluentResource};
use fluent_fallback::Localization;
use fluent_langneg;
use regex::Regex;
use rust_embed::RustEmbed;
use std::{iter, ops, path, str, sync, vec};
use unic_langid::LanguageIdentifier;

static FTL_RESOURCES: &[&str] = &["cli.ftl"];

#[derive(RustEmbed)]
#[folder = "assets/"]
struct Asset;

lazy_static! {
    pub static ref LOCALES: sync::RwLock<Locales> =
        sync::RwLock::new(Locales::new(crate::CASILE.get_string("language").unwrap()));
}

/// Prioritized locale fallback stack
#[derive(Debug)]
pub struct Locales(Vec<LanguageIdentifier>);

impl ops::Deref for Locales {
    type Target = Vec<LanguageIdentifier>;

    fn deref(&self) -> &Vec<LanguageIdentifier> {
        &self.0
    }
}

impl Locales {
    /// Negotiate a locale based on user preference and what we have available
    pub fn new(language: String) -> Locales {
        let language = normalize_lang(&language);
        let available = self::list_available_locales();
        let requested = fluent_langneg::accepted_languages::parse(&language);
        let default: LanguageIdentifier = crate::DEFAULT_LOCALE.parse().unwrap();
        Locales(
            fluent_langneg::negotiate_languages(
                &requested,
                &available,
                Some(&default),
                fluent_langneg::NegotiationStrategy::Filtering,
            )
            .iter()
            .map(|x| *x)
            .cloned()
            .collect(),
        )
    }
}

#[derive(Debug)]
pub struct LocalText {
    key: String,
}

impl LocalText {
    pub fn new(key: &str) -> LocalText {
        LocalText {
            key: String::from(key),
        }
    }

    pub fn fmt(&self, args: Option<&FluentArgs>) -> String {
        translate(&self.key, args)
    }
}

/// Strip off any potential system locale encoding on the end of LC_LANG
fn normalize_lang(input: &String) -> String {
    let re = Regex::new(r"\..*$").unwrap();
    re.replace(&input, "").to_string()
}

// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
fn list_available_locales() -> Vec<LanguageIdentifier> {
    let mut embeded = vec![];
    for asset in Asset::iter() {
        let asset_name = asset.to_string();
        let path = path::Path::new(&asset_name);
        let mut components = path.components();
        if let Some(path::Component::Normal(part)) = components.next() {
            let bytes = part.to_str().unwrap().as_bytes();
            if let Ok(langid) = LanguageIdentifier::from_bytes(bytes) {
                if let Some(path::Component::Normal(part)) = components.next() {
                    if self::FTL_RESOURCES
                        .iter()
                        .any(|v| v == &part.to_str().unwrap())
                    {
                        embeded.push(langid);
                    }
                }
            }
        }
    }
    embeded.dedup();
    embeded
}

fn translate(key: &str, args: Option<&FluentArgs>) -> String {
    let locales = LOCALES.read().unwrap();
    let mut res_path_scheme = path::PathBuf::new();
    res_path_scheme.push("{locale}");
    res_path_scheme.push("{res_id}");
    let generate_messages = |res_ids: &[String]| {
        let mut resolved_locales = locales.iter();
        let res_path_scheme = res_path_scheme.to_str().unwrap();
        let res_ids = res_ids.to_vec();
        iter::from_fn(move || {
            resolved_locales.next().map(|locale| {
                let x = vec![locale.clone()];
                let mut bundle = FluentBundle::new(&x);
                let res_path = res_path_scheme.replace("{locale}", &locale.to_string());
                for res_id in &res_ids {
                    let path = res_path.replace("{res_id}", res_id);
                    if let Some(source) = Asset::get(&path) {
                        let data = str::from_utf8(source.as_ref()).unwrap();
                        let res = FluentResource::try_new(data.to_string()).unwrap();
                        bundle.add_resource(res).unwrap();
                    }
                }
                bundle
            })
        })
    };
    let loc = Localization::new(
        FTL_RESOURCES.iter().map(|s| s.to_string()).collect(),
        generate_messages,
    );
    let value: String = loc.format_value(key, args).to_string();
    value
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn trim_systemd_locale() {
        let out = normalize_lang(&String::from("en_US.utf8"));
        assert_eq!(out, String::from("en_US"));
    }

    #[test]
    fn parse_locale() {
        let out = &fluent_langneg::accepted_languages::parse("tr_tr")[0];
        let tr: LanguageIdentifier = "tr-TR".parse().unwrap();
        assert_eq!(out.to_string(), tr.to_string());
    }
}

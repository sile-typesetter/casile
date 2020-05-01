use elsa::FrozenMap;
use fluent::{FluentBundle, FluentResource};
use fluent_fallback::Localization;
use fluent_langneg;
use regex::Regex;
use rust_embed::RustEmbed;
use std::{env, fs, io, iter, path, str, vec};
use std::collections::HashMap;
use unic_langid::LanguageIdentifier;

static FTL_RESOURCES: &[&str] = &["cli.ftl"];

#[derive(RustEmbed)]
#[folder = "assets/"]
struct Asset;

#[derive(Debug)]
pub struct Locale {
    pub negotiated: Vec<LanguageIdentifier>,
}

impl Locale {
    pub fn negotiate(language: String) -> Locale {
        let language = normalize_lang(language);
        let available = self::list_available_locales();
        let requested = fluent_langneg::accepted_languages::parse(&language);
        let default: LanguageIdentifier = crate::DEFAULT_LOCALE.parse().unwrap();
        let negotiated = fluent_langneg::negotiate_languages(
            &requested,
            &available,
            Some(&default),
            fluent_langneg::NegotiationStrategy::Filtering,
        ).iter().map(|x| *x).cloned().collect();
        Locale {
            negotiated
        }
    }

    pub fn translate(&self, key: &str) -> String {
        let mut res_path_scheme = path::PathBuf::new();
        res_path_scheme.push("{locale}");
        res_path_scheme.push("{res_id}");
        let generate_messages = |res_ids: &[String]| {
        let mut resolved_locales = self.negotiated.iter();
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
        let value: String = loc.format_value(key, None).to_string();
        value
    }
}

/// Strip off any potential system locale encoding on the end of LC_LANG
fn normalize_lang(input: String) -> String {
    let re = Regex::new(r"\..*$").unwrap();
    re.replace(&input, "").to_string()
}

// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
pub fn list_available_locales() -> Vec<LanguageIdentifier> {
    let mut embeded = vec![];
    for asset in Asset::iter() {
        let asset_name = asset.to_string();
        let path = path::Path::new(&asset_name);
        let mut components = path.components();
        if let Some(path::Component::Normal(part)) = components.next() {
            let bytes = part.to_str().unwrap().as_bytes();
            if let Ok(langid) = LanguageIdentifier::from_bytes(bytes) {
                if let Some(path::Component::Normal(part)) = components.next() {
                    if self::FTL_RESOURCES.iter().any(|v| v == &part.to_str().unwrap()) {
                        embeded.push(langid);
                    }
                }
            }

        }
    }
    embeded.dedup();
    embeded
}

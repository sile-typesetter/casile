use std::{env, fs, io, iter};
use fluent::{FluentBundle, FluentResource};
use fluent_fallback::Localization;
use fluent_langneg::{accepted_languages, negotiate_languages, NegotiationStrategy};
use unic_langid::LanguageIdentifier;
use elsa::FrozenMap;
use regex::Regex;

static FLUENT_RESOURCES: &[&str] = &["cli.ftl"];

pub fn init(lang: String) {
    let lang = &normalize_lang(lang);
    let available = self::get_available_locales().expect("Could not find valid BCP47 resource files.");
    let requested = accepted_languages::parse(lang);
    let default: LanguageIdentifier = crate::DEFAULT_LOCALE.parse().unwrap();
    let neg = negotiate_languages(
        &requested,
        &available,
        Some(&default),
        NegotiationStrategy::Filtering,
    );
    // locales = neg;
}

/// Strip off any potential system locale encoding on the end of LC_LANG
fn normalize_lang(input: String) -> String {
    let re = Regex::new(r"\..*$").unwrap();
    re.replace(&input, "").to_string()
}

// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
pub fn get_available_locales() -> Result<Vec<LanguageIdentifier>, io::Error> {
    let mut found_locales = vec![];
    let res_dir = fs::read_dir("./resources/")?;
    for entry in res_dir {
        if let Ok(entry) = entry {
            let path = entry.path();
            if path.is_dir() {
                if let Some(name) = path.file_name() {
                    let bytes = name.to_str().unwrap().as_bytes();
                    if let Ok(langid) = LanguageIdentifier::from_bytes(bytes) {
                        found_locales.push(langid);
                    }
                }
            }
        }
    }
    return Ok(found_locales);
}

pub fn get_str(key: &str) -> &str {
    "bob"
    /*

    let resources: FrozenMap<String, Box<FluentResource>> = FrozenMap::new();
    let mut res_path_scheme = env::current_dir().expect("Failed to retireve current dir.");
    res_path_scheme.push("resources");
    res_path_scheme.push("{locale}");
    res_path_scheme.push("{res_id}");
    let res_path_scheme = res_path_scheme.to_str().unwrap();
    let generate_messages = |res_ids: &[String]| {
        let mut resolved_locales = locales.iter();
        let res_mgr = &resources;
        let res_ids = res_ids.to_vec();

        iter::from_fn(move || {
            resolved_locales.next().map(|locale| {
                let mut bundle = FluentBundle::new(vec![locale.clone()]);
                let res_path = res_path_scheme.replace("{locale}", &locale.to_string());

                for res_id in &res_ids {
                    let path = res_path.replace("{res_id}", res_id);
                    let res = res_mgr.get(&path).unwrap_or_else(|| {
                        let source = crate::read_file(&path).unwrap();
                        let res = FluentResource::try_new(source).unwrap();
                        res_mgr.insert(path.to_string(), Box::new(res))
                    });
                    bundle.add_resource(res).unwrap();
                }
                bundle
            })
        })
    };
    let loc = Localization::new(
        FLUENT_RESOURCES.iter().map(|s| s.to_string()).collect(),
        generate_messages,
    );

    let value = loc.format_value(key, None);
    &value
        */
}

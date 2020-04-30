use elsa::FrozenMap;
use fluent::{FluentBundle, FluentResource};
use fluent_fallback::Localization;
use fluent_langneg;
use regex::Regex;
use std::{env, fs, io, iter, vec};
use std::collections::HashMap;
use unic_langid::LanguageIdentifier;

static FTL_RESOURCE: &str = "cli.ftl";

#[derive(Debug)]
pub struct Locale {
    pub negotiated: Vec<LanguageIdentifier>,
}

impl Locale {
    pub fn negotiate(language: String) -> Locale {
        let language = normalize_lang(language);
        let (available, preloads) = self::load_available_locales().unwrap();
        let requested = fluent_langneg::accepted_languages::parse(&language);
        let default: LanguageIdentifier = crate::DEFAULT_LOCALE.parse().unwrap();
        let negotiated = fluent_langneg::negotiate_languages(
            &requested,
            &available,
            Some(&default),
            fluent_langneg::NegotiationStrategy::Filtering,
        ).iter().map(|x| *x).cloned().collect();
        // println!("PRELOADS: {:#?}", preloads);
        Locale {
            negotiated
        }
    }
}

/// Strip off any potential system locale encoding on the end of LC_LANG
fn normalize_lang(input: String) -> String {
    let re = Regex::new(r"\..*$").unwrap();
    re.replace(&input, "").to_string()
}

#[derive(Debug)]
pub struct FtlData {
    lang: String,
    data: String,
}

impl FtlData {
    pub fn preload(lang: &LanguageIdentifier) -> FtlData {
        let code = lang.to_string();
        FtlData {
            lang: code,
            data: include_str!("../te.ftl").to_string(),
        }
    }
}

// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
pub fn load_available_locales() -> Result<(Vec<LanguageIdentifier>, Vec<FtlData>), io::Error> {
    let mut found_locales = vec![];
    let mut preloads = vec![];
    let res_dir = fs::read_dir("./resources/")?;
    for entry in res_dir {
        if let Ok(entry) = entry {
            let path = entry.path();
            if path.is_dir() {
                if let Some(name) = path.file_name() {
                    let bytes = name.to_str().unwrap().as_bytes();
                    if let Ok(langid) = LanguageIdentifier::from_bytes(bytes) {
                        let mut resource_file = path.clone();
                        resource_file.push(self::FTL_RESOURCE);
                        if let Ok(data) = fs::read_to_string(resource_file) {
                            preloads.push(FtlData::preload(&langid));
                            found_locales.push(langid);
                        }
                    }
                }
            }
        }
    }
    return Ok((found_locales, preloads));
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
        // FLUENT_RESOURCES.iter().map(|s| s.to_string()).collect(),
        generate_messages,
    );

    let value = loc.format_value(key, None);
    &value
        */
}

use crate::activity::ActivityType;
use crate::profile::InterestCategory;
use rand::Rng;
use rand::seq::SliceRandom;

/// Generates realistic URLs and titles based on interests and activity types
pub struct InterestUrlGenerator {
    domains: DomainDatabase,
}

impl InterestUrlGenerator {
    pub fn new() -> Self {
        Self {
            domains: DomainDatabase::new(),
        }
    }

    pub fn generate_url<R: Rng>(
        &self,
        activity_type: &ActivityType,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        match activity_type {
            ActivityType::Search => self.generate_search_url(interest, rng),
            ActivityType::VideoWatch => self.generate_video_url(interest, rng),
            ActivityType::Shopping => self.generate_shopping_url(interest, rng),
            ActivityType::SocialMedia => self.generate_social_url(rng),
            ActivityType::News => self.generate_news_url(interest, rng),
            ActivityType::Research => self.generate_research_url(interest, rng),
            ActivityType::PageVisit => self.generate_page_url(interest, rng),
        }
    }

    fn generate_search_url<R: Rng>(
        &self,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        let query = self.get_search_query(interest, rng);
        let encoded_query = query.replace(" ", "+");

        let search_engine = ["google.com", "bing.com", "duckduckgo.com"]
            .choose(rng)
            .unwrap();

        let url = format!("https://{}/search?q={}", search_engine, encoded_query);
        let title = format!("{} - Search", query);

        (url, title)
    }

    fn generate_video_url<R: Rng>(
        &self,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        let title = self.get_video_title(interest, rng);
        let video_id = self.generate_video_id(rng);

        let platform = ["youtube.com", "vimeo.com"].choose(rng).unwrap();
        let url = if *platform == "youtube.com" {
            format!("https://www.youtube.com/watch?v={}", video_id)
        } else {
            format!("https://vimeo.com/{}", rng.gen_range(100000000..999999999))
        };

        (url, title)
    }

    fn generate_shopping_url<R: Rng>(
        &self,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        let product = self.get_product_name(interest, rng);
        let domain = self.domains.get_shopping_domain(rng);

        let url = format!(
            "https://{}/products/{}",
            domain,
            product.to_lowercase().replace(" ", "-")
        );
        let title = format!("{} - {}", product, domain.split('.').next().unwrap());

        (url, title)
    }

    fn generate_social_url<R: Rng>(&self, rng: &mut R) -> (String, String) {
        let platforms = vec![
            ("twitter.com", "Twitter"),
            ("reddit.com", "Reddit"),
            ("facebook.com", "Facebook"),
            ("instagram.com", "Instagram"),
            ("linkedin.com", "LinkedIn"),
            ("mastodon.social", "Mastodon"),
            ("bsky.app", "Bluesky"),
        ];

        let (domain, name) = platforms.choose(rng).unwrap();
        let url = format!("https://{}", domain);
        let title = format!("Home - {}", name);

        (url, title)
    }

    fn generate_news_url<R: Rng>(
        &self,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        let domain = self.domains.get_news_domain(rng);
        let headline = self.get_news_headline(interest, rng);

        let slug = headline
            .to_lowercase()
            .chars()
            .map(|c| if c.is_alphanumeric() || c == ' ' { c } else { ' ' })
            .collect::<String>()
            .split_whitespace()
            .take(8)
            .collect::<Vec<_>>()
            .join("-");

        let url = format!("https://{}/article/{}", domain, slug);
        let title = format!("{} - {}", headline, domain.split('.').next().unwrap());

        (url, title)
    }

    fn generate_research_url<R: Rng>(
        &self,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        let domain = self.domains.get_research_domain(rng);
        let topic = self.get_research_topic(interest, rng);

        let url = if domain.contains("wikipedia") {
            format!("https://{}/wiki/{}", domain, topic.replace(" ", "_"))
        } else {
            format!("https://{}/article/{}", domain, topic.to_lowercase().replace(" ", "-"))
        };

        let title = format!("{} - {}", topic, domain.split('.').next().unwrap());

        (url, title)
    }

    fn generate_page_url<R: Rng>(
        &self,
        interest: &Option<InterestCategory>,
        rng: &mut R,
    ) -> (String, String) {
        let domain = self.domains.get_interest_domain(interest, rng);
        let page = self.get_page_title(interest, rng);

        let url = format!(
            "https://{}/{}",
            domain,
            page.to_lowercase().replace(" ", "-")
        );
        let title = format!("{} | {}", page, domain.split('.').next().unwrap());

        (url, title)
    }

    fn get_search_query<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> String {
        if let Some(cat) = interest {
            let queries = match cat {
                InterestCategory::Technology => vec![
                    "latest smartphones 2026", "cloud computing trends", "AI news today",
                    "tech reviews OLED monitors", "best laptop for programming",
                    "mesh wifi router comparison", "solid state drive vs NVMe",
                    "mechanical keyboard switches guide", "USB-C hub recommendations",
                    "smart home automation setup", "VPN service comparison",
                    "open source alternatives to popular software",
                ],
                InterestCategory::Gaming => vec![
                    "best RPG games 2026", "gaming benchmarks RTX 5080",
                    "esports tournament schedule", "indie game reviews",
                    "retro gaming emulator setup", "steam deck accessories",
                    "cozy simulation games", "game soundtrack playlists",
                    "speedrun world records", "board game night recommendations",
                    "gaming monitor 240hz deals",
                ],
                InterestCategory::Sports => vec![
                    "football scores today", "NBA highlights last night",
                    "soccer transfer rumors", "sports statistics databases",
                    "marathon training plan beginner", "cycling routes near me",
                    "tennis racquet reviews", "swimming technique drills",
                    "rock climbing gym nearby", "sports injury prevention stretches",
                ],
                InterestCategory::Fitness => vec![
                    "beginner strength training program", "yoga for flexibility",
                    "HIIT workout at home no equipment", "protein shake recipes",
                    "running form correction tips", "foam rolling routine",
                    "calisthenics progression chart", "heart rate zone training",
                    "meal prep for muscle gain", "stretching routine morning",
                ],
                InterestCategory::Cooking => vec![
                    "easy weeknight dinner recipes", "meal prep ideas for the week",
                    "sourdough bread starter guide", "healthy meals under 30 minutes",
                    "authentic pad thai recipe", "homemade pasta from scratch",
                    "fermented vegetables tutorial", "espresso extraction technique",
                    "knife sharpening whetstone guide", "seasonal produce guide spring",
                    "cast iron skillet care", "slow cooker recipes dump and go",
                ],
                InterestCategory::Travel => vec![
                    "best travel destinations off the beaten path",
                    "cheap flights Europe spring", "hotel reviews Kyoto Japan",
                    "travel packing list minimalist", "road trip itinerary southwest USA",
                    "train travel across Europe tips", "travel photography gear",
                    "solo travel safety tips", "best hostels in Lisbon",
                    "travel insurance comparison 2026", "digital nomad visa countries",
                ],
                InterestCategory::Fashion => vec![
                    "sustainable fashion brands 2026", "capsule wardrobe essentials",
                    "vintage clothing stores online", "sneaker release calendar",
                    "how to style linen pants", "affordable watch brands",
                    "thrift store shopping tips", "fashion trends spring 2026",
                ],
                InterestCategory::Music => vec![
                    "new album releases this week", "vinyl record player setup",
                    "learn guitar online free", "music theory basics",
                    "concert tickets local venues", "best headphones for audiophiles",
                    "synthesizer beginner guide", "music production DAW comparison",
                    "jazz history documentary", "classical music for studying",
                ],
                InterestCategory::Movies => vec![
                    "best movies 2026 so far", "indie film festival schedule",
                    "classic cinema recommendations", "movie streaming comparison",
                    "film photography developing at home", "documentary recommendations",
                    "foreign language films subtitles", "movie theater near me showtimes",
                ],
                InterestCategory::Books => vec![
                    "best books to read 2026", "local bookstore events",
                    "book club recommendations fiction", "audiobook app comparison",
                    "Slovenian poetry English translations", "used bookstores online",
                    "science fiction new releases", "literary magazine submissions",
                    "speed reading techniques", "rare book collecting guide",
                ],
                InterestCategory::Art => vec![
                    "art museum exhibitions current", "watercolor painting tutorial",
                    "digital art tablet comparison", "street art murals city guide",
                    "pottery wheel classes near me", "art history timeline overview",
                    "printmaking techniques linocut", "gallery opening nights local",
                ],
                InterestCategory::Science => vec![
                    "latest scientific discoveries 2026", "citizen science projects",
                    "astronomy events this month", "climate research recent papers",
                    "quantum computing explained simply", "biology podcast recommendations",
                    "chemistry experiments at home safe", "science museum exhibits",
                ],
                InterestCategory::Finance => vec![
                    "stock market analysis today", "index fund comparison",
                    "cryptocurrency market trends", "financial planning for beginners",
                    "budget spreadsheet template", "tax deductions checklist",
                    "retirement savings calculator", "real estate market forecast",
                    "emergency fund how much", "credit score improvement tips",
                ],
                InterestCategory::Programming => vec![
                    "rust programming tutorial", "functional programming patterns",
                    "algorithm visualization interactive", "code review best practices",
                    "WebAssembly getting started", "open source projects to contribute",
                    "system design interview prep", "database indexing explained",
                    "git workflow branching strategies", "API design REST vs GraphQL",
                    "Linux command line cheat sheet", "container orchestration comparison",
                ],
                InterestCategory::HomeImprovement => vec![
                    "DIY home renovation ideas", "how to fix a leaky faucet",
                    "paint color trends 2026", "hardwood floor refinishing guide",
                    "smart thermostat installation", "bathroom remodel budget",
                    "raised garden bed plans", "tool organization garage",
                ],
                InterestCategory::Gardening => vec![
                    "vegetable garden planting schedule", "indoor plant care guide",
                    "composting for beginners", "native plants for pollinators",
                    "herb garden window box", "raised bed soil mixture recipe",
                    "pruning fruit trees when", "seed starting indoors timeline",
                ],
                InterestCategory::Photography => vec![
                    "landscape photography composition tips", "mirrorless camera comparison",
                    "photo editing software free", "street photography etiquette",
                    "astrophotography beginner guide", "film photography developing chemicals",
                    "portrait lighting setup natural", "macro photography equipment",
                ],
                InterestCategory::DataScience => vec![
                    "machine learning project ideas", "data visualization tools comparison",
                    "statistical analysis course free", "big data processing frameworks",
                    "natural language processing tutorial", "data ethics and privacy",
                    "time series forecasting methods", "A/B testing sample size calculator",
                ],
                _ => vec![
                    "latest news today", "trending topics this week",
                    "popular articles to read", "how to guides online",
                    "best podcasts 2026", "local events this weekend",
                    "weather forecast 10 day", "recipe of the day",
                ],
            };
            queries.choose(rng).unwrap().to_string()
        } else {
            vec![
                "news today", "weather forecast", "easy recipes dinner",
                "product reviews", "local events near me", "how to tips",
                "best deals online", "interesting facts",
            ]
            .choose(rng)
            .unwrap()
            .to_string()
        }
    }

    fn get_video_title<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> String {
        if let Some(cat) = interest {
            let titles = match cat {
                InterestCategory::Technology => vec![
                    "Tech Review: Latest Gadgets", "Programming Tutorial for Beginners",
                    "Tech News Weekly Roundup", "Unboxing the New Flagship Phone",
                    "Home Lab Server Build", "Linux Desktop Setup Guide",
                ],
                InterestCategory::Gaming => vec![
                    "Full Gameplay Walkthrough Part 1", "Gaming News and Rumors",
                    "Top 10 Games This Month", "Retro Game Restoration",
                    "Competitive Match Highlights", "Game Dev Behind the Scenes",
                ],
                InterestCategory::Cooking => vec![
                    "Quick Weeknight Recipe Tutorial", "Advanced Cooking Techniques",
                    "Street Food Tour Around the World", "Baking Bread from Scratch",
                    "Kitchen Gadget Testing", "Restaurant vs Homemade Challenge",
                ],
                InterestCategory::Music => vec![
                    "Official Music Video Premiere", "Live Concert Performance Full",
                    "Album Review and Analysis", "Guitar Lesson Beginner to Advanced",
                    "Music Production Tips in the DAW", "Vinyl Record Collection Tour",
                ],
                InterestCategory::Fitness => vec![
                    "Full Body Workout No Equipment", "Yoga Flow for Beginners",
                    "Marathon Training Vlog Week 1", "Form Check Common Mistakes",
                    "Mobility Routine 15 Minutes", "Nutrition Guide for Athletes",
                ],
                InterestCategory::Travel => vec![
                    "Hidden Gems You Must Visit", "Budget Travel Tips Europe",
                    "Solo Travel Vlog Japan", "Van Life Conversion Complete",
                    "Best Street Food Markets", "Train Journey Across Countryside",
                ],
                InterestCategory::Science => vec![
                    "Mind-Blowing Science Experiments", "Space Documentary Latest Missions",
                    "How This Technology Actually Works", "The Physics of Everyday Things",
                ],
                _ => vec![
                    "Popular Video This Week", "Trending Content You Missed",
                    "Featured Video of the Day", "Must Watch Documentary",
                    "How-To Guide Step by Step",
                ],
            };
            titles.choose(rng).unwrap().to_string()
        } else {
            "Trending Video".to_string()
        }
    }

    fn get_product_name<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> String {
        if let Some(cat) = interest {
            let products = match cat {
                InterestCategory::Technology => vec![
                    "Wireless Noise-Cancelling Headphones", "Smart Watch Fitness Tracker",
                    "Adjustable Laptop Stand", "USB-C Multiport Hub",
                    "Mechanical Keyboard Cherry MX", "4K Webcam with Ring Light",
                    "Portable SSD 2TB", "Smart Home Speaker",
                ],
                InterestCategory::Gaming => vec![
                    "Ergonomic Gaming Mouse", "Hot-Swap Mechanical Keyboard",
                    "Gaming Chair Lumbar Support", "Surround Sound Headset",
                    "RGB LED Strip Kit", "Controller Charging Dock",
                    "Gaming Monitor 27 inch", "Stream Deck Controller",
                ],
                InterestCategory::Fitness => vec![
                    "Non-Slip Yoga Mat", "Fabric Resistance Bands Set",
                    "Insulated Water Bottle 32oz", "Whey Protein Powder Chocolate",
                    "Adjustable Dumbbell Set", "Foam Roller High Density",
                    "Jump Rope Speed Cable", "Running Shoes Cushioned",
                ],
                InterestCategory::Cooking => vec![
                    "Japanese Chef Knife 8 inch", "Bamboo Cutting Board Set",
                    "Stainless Steel Cookware 10 Piece", "Digital Kitchen Scale",
                    "Cast Iron Dutch Oven", "Espresso Machine Barista",
                    "Instant Read Thermometer", "Silicone Baking Mat Set",
                ],
                InterestCategory::Fashion => vec![
                    "Sustainable Cotton Jacket", "Minimalist Leather Sneakers",
                    "Automatic Watch Japanese Movement", "Polarized Sunglasses UV400",
                    "Merino Wool Base Layer", "Canvas Tote Bag Organic",
                    "Linen Button Down Shirt", "Recycled Fabric Backpack",
                ],
                InterestCategory::Photography => vec![
                    "Camera Tripod Carbon Fiber", "ND Filter Set 82mm",
                    "Camera Bag Waterproof", "Memory Card 256GB V90",
                    "Photo Printing Service", "Lightbox Product Photography",
                ],
                InterestCategory::Gardening => vec![
                    "Raised Garden Bed Kit", "Pruning Shears Bypass",
                    "Seed Starting Tray Heat Mat", "Garden Hose Expandable",
                    "Composting Bin Tumbler", "Plant Grow Light LED",
                ],
                _ => vec![
                    "Popular Item of the Week", "Bestselling Product",
                    "Featured Deal Today", "Top Rated by Customers",
                    "Editor's Choice Pick", "New Arrival",
                ],
            };
            products.choose(rng).unwrap().to_string()
        } else {
            "Product".to_string()
        }
    }

    fn get_news_headline<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> String {
        if let Some(cat) = interest {
            let headlines = match cat {
                InterestCategory::Technology => vec![
                    "Major Tech Company Announces Revolutionary New Product",
                    "Breakthrough in AI Research Could Transform Healthcare",
                    "Cybersecurity Alert: New Vulnerability Affects Millions",
                    "Open Source Project Reaches Major Milestone",
                    "Quantum Computing Startup Secures Record Funding",
                    "Privacy Regulations Tighten as Data Breaches Increase",
                ],
                InterestCategory::Politics => vec![
                    "Election Results Coming In From Key Districts",
                    "Major Policy Change Announced at Press Conference",
                    "International Summit Concludes with New Agreement",
                    "Local Government Approves Infrastructure Plan",
                    "Bipartisan Bill Passes Committee Vote",
                ],
                InterestCategory::Sports => vec![
                    "Championship Game Recap and Analysis",
                    "Veteran Player Breaks Long-Standing Record",
                    "Underdog Team Makes Stunning Playoff Run",
                    "Transfer Window Brings Surprising Moves",
                    "Olympic Committee Announces Host City",
                ],
                InterestCategory::Science => vec![
                    "New Discovery Could Rewrite Textbook Understanding",
                    "Research Team Publishes Groundbreaking Findings",
                    "Space Mission Successfully Deploys New Instrument",
                    "Climate Study Reveals Unexpected Trend",
                    "Gene Therapy Trial Shows Promising Results",
                ],
                InterestCategory::Finance => vec![
                    "Markets React to Central Bank Announcement",
                    "Tech Sector Leads Weekly Market Rally",
                    "Housing Market Shows Signs of Stabilization",
                    "Cryptocurrency Regulation Framework Proposed",
                    "Small Business Optimism Index Rises",
                ],
                _ => vec![
                    "Breaking: Significant Development Reported Today",
                    "Latest Updates From Around the World",
                    "Today's Top Stories You Need to Know",
                    "Community Event Draws Record Attendance",
                    "Weather Pattern Shift Expected This Week",
                ],
            };
            headlines.choose(rng).unwrap().to_string()
        } else {
            "Breaking News".to_string()
        }
    }

    fn get_research_topic<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> String {
        if let Some(cat) = interest {
            let topics = match cat {
                InterestCategory::Science => vec![
                    "Quantum Field Theory", "Climate Feedback Loops",
                    "CRISPR Gene Editing Applications", "Exoplanet Atmospheres",
                    "Neuroscience of Learning", "Microbiome and Immunity",
                    "Renewable Energy Storage", "Deep Sea Ecosystems",
                ],
                InterestCategory::Technology => vec![
                    "Transformer Architecture Neural Networks", "Blockchain Consensus Mechanisms",
                    "Quantum Error Correction", "Zero Knowledge Proofs",
                    "Homomorphic Encryption", "Edge Computing Architectures",
                    "WebAssembly Runtime Design", "Formal Verification Methods",
                ],
                InterestCategory::Programming => vec![
                    "Type System Design Patterns", "Concurrent Data Structures",
                    "Compiler Optimization Passes", "Distributed Systems Consensus",
                    "Memory Safety without Garbage Collection", "Property-Based Testing",
                    "Category Theory for Programmers", "Effect Systems",
                ],
                InterestCategory::DataScience => vec![
                    "Bayesian Statistical Methods", "Causal Inference Frameworks",
                    "Dimensionality Reduction Techniques", "Time Series Anomaly Detection",
                    "Federated Learning Privacy", "Graph Neural Networks",
                    "Interpretable Machine Learning", "Reinforcement Learning Environments",
                ],
                InterestCategory::Art => vec![
                    "Renaissance Art Techniques", "Contemporary Installation Art",
                    "Color Theory and Perception", "Art Conservation Methods",
                    "Digital Art and NFT Criticism", "Bauhaus Design Principles",
                ],
                _ => vec![
                    "General Knowledge Compilation", "Encyclopedia Reference Article",
                    "Historical Overview and Analysis", "Comparative Study Guide",
                    "Methodology and Frameworks", "Literature Review Summary",
                ],
            };
            topics.choose(rng).unwrap().to_string()
        } else {
            "General Topic".to_string()
        }
    }

    fn get_page_title<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> String {
        if let Some(cat) = interest {
            let pages = match cat {
                InterestCategory::Technology => vec![
                    "Getting Started Guide", "Product Comparison Chart",
                    "Troubleshooting Common Issues", "Release Notes and Changelog",
                    "Community Forum Discussion",
                ],
                InterestCategory::Cooking => vec![
                    "Recipe Collection Seasonal", "Ingredient Substitution Guide",
                    "Kitchen Equipment Buying Guide", "Cooking Times Reference Chart",
                    "Wine Pairing Suggestions",
                ],
                InterestCategory::Travel => vec![
                    "Destination Guide Complete", "Packing Checklist Printable",
                    "Budget Breakdown Per Day", "Local Customs and Etiquette",
                    "Transportation Options Compared",
                ],
                _ => vec![
                    "Complete Guide and Overview", "Frequently Asked Questions",
                    "Tips and Best Practices", "Resource Directory",
                    "Community Recommendations",
                ],
            };
            pages.choose(rng).unwrap().to_string()
        } else {
            "General Page".to_string()
        }
    }

    fn generate_video_id<R: Rng>(&self, rng: &mut R) -> String {
        const CHARS: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
        (0..11)
            .map(|_| CHARS[rng.gen_range(0..CHARS.len())] as char)
            .collect()
    }
}

struct DomainDatabase {
    shopping: Vec<&'static str>,
    news: Vec<&'static str>,
    research: Vec<&'static str>,
    specialty: Vec<(&'static str, &'static str)>, // (domain, category)
}

impl DomainDatabase {
    fn new() -> Self {
        Self {
            shopping: vec![
                "amazon.com", "ebay.com", "etsy.com", "walmart.com", "bestbuy.com",
                "newegg.com", "target.com", "wayfair.com", "rei.com", "zappos.com",
                "bookshop.org", "thriftbooks.com",
            ],
            news: vec![
                "bbc.com", "cnn.com", "reuters.com", "theguardian.com", "nytimes.com",
                "apnews.com", "npr.org", "aljazeera.com", "theatlantic.com", "propublica.org",
            ],
            research: vec![
                "wikipedia.org", "britannica.com", "scholar.google.com", "arxiv.org",
                "jstor.org", "pubmed.ncbi.nlm.nih.gov", "semanticscholar.org",
                "researchgate.net", "ssrn.com",
            ],
            specialty: vec![
                ("instructables.com", "DIY"),
                ("allrecipes.com", "Cooking"),
                ("bonappetit.com", "Cooking"),
                ("seriouseats.com", "Cooking"),
                ("lonelyplanet.com", "Travel"),
                ("atlasobscura.com", "Travel"),
                ("500px.com", "Photography"),
                ("dpreview.com", "Photography"),
                ("goodreads.com", "Books"),
                ("pitchfork.com", "Music"),
                ("bandcamp.com", "Music"),
                ("artsy.net", "Art"),
                ("behance.net", "Art"),
                ("nature.com", "Science"),
                ("sciencedaily.com", "Science"),
            ],
        }
    }

    fn get_shopping_domain<R: Rng>(&self, rng: &mut R) -> &str {
        self.shopping.choose(rng).unwrap()
    }

    fn get_news_domain<R: Rng>(&self, rng: &mut R) -> &str {
        self.news.choose(rng).unwrap()
    }

    fn get_research_domain<R: Rng>(&self, rng: &mut R) -> &str {
        self.research.choose(rng).unwrap()
    }

    fn get_interest_domain<R: Rng>(&self, interest: &Option<InterestCategory>, rng: &mut R) -> &str {
        if let Some(cat) = interest {
            match cat {
                InterestCategory::Technology => {
                    *vec!["techcrunch.com", "theverge.com", "arstechnica.com", "hackaday.com", "wired.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Gaming => {
                    *vec!["ign.com", "gamespot.com", "polygon.com", "kotaku.com", "pcgamer.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Sports => {
                    *vec!["espn.com", "bleacherreport.com", "si.com", "theathletic.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Cooking => {
                    *vec!["allrecipes.com", "foodnetwork.com", "bonappetit.com", "seriouseats.com", "budgetbytes.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Travel => {
                    *vec!["lonelyplanet.com", "tripadvisor.com", "atlasobscura.com", "nomadicmatt.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Music => {
                    *vec!["pitchfork.com", "bandcamp.com", "last.fm", "stereogum.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Photography => {
                    *vec!["500px.com", "dpreview.com", "petapixel.com", "flickr.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Programming => {
                    *vec!["stackoverflow.com", "dev.to", "lobste.rs", "news.ycombinator.com", "github.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Fitness => {
                    *vec!["bodybuilding.com", "runnersworld.com", "nerdfitness.com", "stronglifts.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Books => {
                    *vec!["goodreads.com", "bookshop.org", "lithub.com", "theparisreview.org"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Art => {
                    *vec!["artsy.net", "behance.net", "deviantart.com", "artstation.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Finance => {
                    *vec!["investopedia.com", "marketwatch.com", "seekingalpha.com", "morningstar.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::Gardening => {
                    *vec!["gardeningknowhow.com", "almanac.com", "savvygardening.com"]
                        .choose(rng).unwrap()
                }
                InterestCategory::HomeImprovement => {
                    *vec!["thisoldhouse.com", "familyhandyman.com", "bobvila.com"]
                        .choose(rng).unwrap()
                }
                _ => "example.com",
            }
        } else {
            "example.com"
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rand::SeedableRng;
    use rand::rngs::SmallRng;

    #[test]
    fn test_search_query_diversity() {
        let gen = InterestUrlGenerator::new();
        let mut rng = SmallRng::seed_from_u64(42);

        let categories = vec![
            InterestCategory::Technology,
            InterestCategory::Cooking,
            InterestCategory::Travel,
            InterestCategory::Programming,
        ];

        for cat in &categories {
            let mut queries = std::collections::HashSet::new();
            for _ in 0..20 {
                let q = gen.get_search_query(&Some(cat.clone()), &mut rng);
                queries.insert(q);
            }
            // Each category should produce at least 4 unique queries
            assert!(queries.len() >= 4, "Category {:?} only produced {} unique queries", cat, queries.len());
        }
    }

    #[test]
    fn test_url_generation_all_types() {
        let gen = InterestUrlGenerator::new();
        let mut rng = SmallRng::seed_from_u64(99);
        let interest = Some(InterestCategory::Technology);

        let types = vec![
            ActivityType::Search, ActivityType::VideoWatch, ActivityType::Shopping,
            ActivityType::SocialMedia, ActivityType::News, ActivityType::Research,
            ActivityType::PageVisit,
        ];

        for at in &types {
            let (url, title) = gen.generate_url(at, &interest, &mut rng);
            assert!(url.starts_with("https://"), "URL for {:?} doesn't start with https://", at);
            assert!(!title.is_empty(), "Title for {:?} is empty", at);
        }
    }
}

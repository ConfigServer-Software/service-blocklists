
<div align="center">

🕙 `Last Sync: 05/12/2026 05:05 UTC`

</div>

<div align="center">
<h6>♾️ Firewall Blocklist Service ♾️</h1>
</div>

<div align="center">

<img src="docs/images/logos/csf_01.png" height="230">

<!-- prettier-ignore-start -->
[![Size][github-size-img]][github-size-img]
[![Last Commit][github-commit-img]][github-commit-img]
[![Contributors][contribs-all-img]](#contributors-)

[![View Official Documentation](https://img.shields.io/badge/View_Official_Documentation-526CFE?style=for-the-badge&logo=MaterialForMkDocs&logoColor=white)](https://blocklist.configserver.dev/help)
<!-- prettier-ignore-end -->

<div align="center">

[![View](https://img.shields.io/discord/1428601317361848412?style=for-the-badge&color=de1f68)](https://discord.configserver.dev)[![View](https://img.shields.io/badge/Join%20Discord-2d5e97?style=for-the-badge&logo=discord&logoColor=FFFFFF)](https://discord.configserver.dev)

</div>


<br />
<br />

</div>

<br />

<div align="center">

<br />

<p float="left">
    <img style="padding-right:15px;" src="https://raw.githubusercontent.com/ConfigServerApps/service-blocklists/refs/heads/main/docs/images/service/01.png" width="300" />
    <img src="https://raw.githubusercontent.com/ConfigServerApps/service-blocklists/refs/heads/main/docs/images/service/02.png" width="300" /> 
</p>

</div>

<br />

---

<br />

- [Introduction](#introduction)
  - [About](#about)
  - [What Are Blocklists?](#what-are-blocklists)
- [Supported Blocklists](#supported-blocklists)
  - [Official Blocklists](#official-blocklists)
  - [Third-Party Blocklists](#third-party-blocklists)
- [Download Options](#download-options)
  - [Github Repository](#github-repository)
  - [API Service](#api-service)
- [Blocklists](#blocklists)
  - [Risk Assessments](#risk-assessments)
  - [Official Blocklists](#official-blocklists-1)
    - [Recommended](#recommended)
    - [Privacy](#privacy)
    - [Spam](#spam)
    - [Internet Service Providers](#internet-service-providers)
    - [Transmission (BitTorrent Client)](#transmission-bittorrent-client)
    - [Geographical Databases](#geographical-databases)
      - [Summary](#summary)
      - [Continents](#continents)
      - [Countries](#countries)
  - [Third-Party Blocklists](#third-party-blocklists-1)
- [References for More Help](#references-for-more-help)
- [Contributors ✨](#contributors-)

<br />

---

<br />

## Introduction

This section outlines what we offer through our blocklist service.

<br />

### About

This service provides downloadable IP blocklists to help protect servers, applications, and network infrastructure from unwanted or malicious traffic.

Blocklists are used to block known abusive IPs involved in attacks, spam, bot activity, scanning, crawling, VPN/proxy usage, datacenter traffic, and other suspicious behavior before a connection is allowed.

All lists are provided in standard `ipset` format, with one IP address or subnet per line. This simple format is widely supported and easy to integrate into firewalls, intrusion prevention systems, routers, proxies, and other security tools on both Linux and cloud platforms.

Blocklists can be used with a wide range of security and firewall tools, including:

- [Cloudflare firewall rules](https://developers.cloudflare.com/firewall/cf-firewall-rules/) (via IP lists)
- [ConfigServer Security & Firewall](https://github.com/Aetherinox/csf-firewall)
- [CrowdSec](https://www.crowdsec.net)
- [Fail2ban](https://github.com/fail2ban/fail2ban)
- [FireHOL](https://firehol.org/)
- [iptables](https://en.wikipedia.org/wiki/Iptables) / [nftables](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page)
- [Mikrotik RouterOS](https://mikrotik.com/software)
- [OPNsense](https://opnsense.org/)
- [pfSense](https://www.pfsense.org/)
- [Transmission](https://transmissionbt.com/)
- [UFW (Uncomplicated Firewall)](https://en.wikipedia.org/wiki/Uncomplicated_Firewall)

<br/>
<br/>

### What Are Blocklists?

Blocklists (also known as *ipsets*) are collections of IP addresses and networks associated with malicious or unwanted activity. These typically include sources involved in spamming, brute-force attacks, botnets, scanning activity, and other forms of abuse.

When used with firewall or security software, blocklists can automatically block or restrict traffic from these sources. This helps reduce the risk of compromise, improve resilience against attacks, and minimize unwanted network noise.

By proactively filtering traffic at the network level, blocklists allow you to strengthen your security posture without needing to manually monitor or respond to every incoming connection.

<br>

Using blocklists within these tools allows for automated, consistent protection across servers, networks, and cloud infrastructure.

<br />

---

<br />

## Supported Blocklists

We offer a broad range of blocklists, combining our own in-house curated list, along with trusted third-party sources. Together, these lists are designed to help you effectively block abusive, unwanted, and high-risk traffic.

This section provides an overview of the blocklists available through our platform.

For the complete and up-to-date list of supported blocklists, please refer to our API endpoint:

- https://blocklist.configserver.dev/lists

<br />
<br />

### Official Blocklists

Our blocklist service provides continuously updated IP-based (ipset) protection against today’s most active online threats. These lists are exclusively curated in-house and are only available through our service, giving you access to intelligence not found in other public blocklists.

We target a wide range of abusive activity, including brute-force attack sources, spam networks, malicious scanners, and hosting providers that are commonly abused for harmful or unauthorized activity.

To enhance accuracy and coverage, we combine our internal system with trusted external intelligence sources, including organizations such as the American Registry for Internet Numbers (ARIN) and other reputable security feeds.

Our blocklists are updated multiple times per day to ensure protection stays current against new potential threats.

Coverage includes:

- Countries and continents (geo-blocking options)
- Major ISPs (e.g. AT&T, Comcast, Starlink)
- Hosting providers (e.g. AWS, DigitalOcean, Contabo)
- Known spam sources
- BitTorrent-related networks
- AI crawlers (e.g. OpenAI, Anthropic)
- VPNs and proxy networks

<br />

You can view our official blocklists [here](#official-blocklists-1).

<br />
<br />

### Third-Party Blocklists

In addition to our in-house curated blocklists, we also provide access to some of the most widely used and trusted third-party threat intelligence feeds available.

These external sources are integrated into our platform to extend coverage and improve detection of malicious activity across a broader global threat landscape. T

These blocklists help identify additional spam networks, scanning infrastructure, bot activity, and compromised hosts that may not be captured by internal datasets alone.

We currently integrate providers such as:

- [AlienVault](http://alienvault.com/)
- [BBcan177](https://gist.github.com/BBcan177/)
- [Binary Defense](https://binarydefense.com)
- [blocklist.de](https://lists.blocklist.de/)
- [Botvrij](http://www.botvrij.eu/)
- [Emerging Threats](https://rules.emergingthreats.net/blockrules/)
- [Myip.ms](https://myip.ms/)
- [Spamhaus](https://www.spamhaus.org/)
- And other reputable security feeds

<br />

You can view our 3rd-party provider blocklists [here](#third-party-blocklists).

<br />

---

<br />

## Download Options

We provide access to our blocklists through two methods:

1. A free public repository available on [GitHub](https://github.com/ConfigServerApps/service-blocklists).
2. Our advanced [Blocklist API](https://blocklist.configserver.dev).

<br />

### Github Repository

We provide a free version of our blocklists through our public [Github repository](https://github.com/ConfigServerApps/service-blocklists), allowing anyone to download and use our blocklists at no cost. 

<br />

### API Service

In addition to the free repository, we offer users access to our **Blocklist API Service**, which provides advanced customization features that are not possible through static GitHub-hosted files.

Our API allows you to:

- Remove all comments from blocklists
- Inject custom IP addresses into generated lists
- Exclude specific IPs or subnets
- Filter entries using wildcard matching
- Limit the number of returned IPs
- Add custom header notes to generated lists
- Filter by IPv4 or IPv6
- Access higher request and download limits

These features enable precise control over how blocklists are generated, making it easier to tailor them to your firewall rules, infrastructure, and security requirements.

For more details on API access and available plans, see our [Membership](https://blocklist.configserver.dev/help#section-about-membership-tiers) page.

Users who subscribe to a [membership](https://blocklist.configserver.dev/help#section-about-membership-tiers) will be provided an **API license key** which gives you direct access to all blocklist API features.

<br />

---

<br />

## Blocklists

This section lists all of the available blocklists; and explains about our [risk assessment](#risk-assessments) procedure.

<br />

### Risk Assessments

Blocklists in this README use `⚝` and `★` icons to indicate risk levels. 

More stars mean higher risk. Lists marked as **High** or **Critical** should be added to your firewall application blocklist to secure your server. Lower-risk lists are optional and can be added at your discretion.

Our automated CI generates this risk assessment each day.

| Rating            | Risk Level        | Description                                                              |
|-------------------|-------------------|--------------------------------------------------------------------------|
| `⚝⚝⚝⚝⚝`         | No Risk           | Trusted or benign infrastructure with no meaningful threat indicators.   |
| `★⚝⚝⚝⚝`         | Low Risk          | Generally safe networks with very limited or incidental abuse signals.   |
| `★★⚝⚝⚝`         | Moderate Risk     | Mixed or uncertain sources; may exhibit occasional suspicious activity.  |
| `★★★⚝⚝`         | Elevated Risk     | Known to generate abuse traffic; blocking may be justified.              |
| `★★★★⚝`         | High Risk         | Strong association with malicious or automated abuse activity.           |
| `★★★★★`         | Critical Risk     | Highly malicious or heavily abused infrastructure; block immediately.    |

<br />
<br />

### Official Blocklists

This repository provides our in-house curated blocklists, which are automatically updated multiple times per day. These lists can be integrated into supported firewall applications. Please refer to your specific application’s documentation for setup instructions.

<br />

#### Recommended

These are the primary IPSETs most users will want to add to their firewall configuration. They contain actively observed IP addresses linked to recent abusive behavior across multiple threat intelligence sources.

Each IP is validated against trusted third-party providers and processed through multiple backend verification systems designed to minimize false positives as much as possible.

Our goal is to ensure that entries included in these lists have a very high confidence level, making them safe and reliable for production firewall use.

IPs included in these lists are associated with activities such as:

- SSH brute-force attempts
- Port scanning and reconnaissance
- DDoS attack participation
- IoT device targeting
- Phishing infrastructure

<br />

> [!note]
> For most users, the blocklists `master.ipset` and `highrisk.ipset` are all you need. They contain a massive collection of IP addresses, all with a 100% confidence level, meaning you should encounter none or minimal false positives.

<br />

| Set                  | Description                                                                                                                                                                                                                                                                                                                   | Severity | View                                                           |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|----------------------------------------------------------------|
| `Master Blocklist`   | <sub>Abusive IP addresses which have been reported for port scanning and SSH brute-forcing. HIGHLY recommended. <br> <sub><sup>Includes [AbuseIPDB](https://www.abuseipdb.com/), [IPThreat](https://ipthreat.net/), [CinsScore](https://cinsscore.com), [GreensNow](https://blocklist.greensnow.co/greensnow.txt)</sup></sub> | ★★★★★    | [view](https://blocklist.configserver.dev/master.ipset)        |
| `High Risk Networks` | <sub>Networks identified engaging in malicious activity such as port scanning, SSH/SFTP brute-force attempts, and probing web servers with common sensitive filenames (e.g. .env) in an attempt to discover exposed private data. Confidence: 100% </sub>                                                                     | ★★★★★    | [view](https://blocklist.configserver.dev/highrisk.ipset)      |
| `Bogon Networks`     | <sub>Unroutable, reserved, or unallocated IP ranges that should not appear on the public internet. Often used for spoofing or misconfigured traffic. </sub>                                                                                                                                                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/bogon.ipset)         |
| `Tor Exit Nodes`     | <sub>Public exit points of the Tor network used for anonymized traffic routing. Commonly associated with privacy usage, but also frequently used for abuse and automated attacks. </sub>                                                                                                                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/tor_exitnodes.ipset) |

<br />
<br />
<br />

#### Privacy

These blocklists help you control which third-party services can access your server, allowing you to block bad actors or unwanted service providers.

<br />

| Set                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Severity | View                                                                                |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------|
| `General`                        | A collection of known internet measurement, scanning, research, and security intelligence networks that actively probe public infrastructure.<br><sub><sup>List includes [Censys](https://censys.io), [Shodan](https://shodan.io/), [Project25499](https://blogproject25499.wordpress.com/), [InternetArchive](https://archive.org/), [Cyber Resilience](https://cyberresilience.io), [Internet Measurement](https://internet-measurement.com), [probe.onyphe.net](https://onyphe.net), [Security Trails](https://securitytrails.com)</sup></sub> | ★★★★★    | [view](https://blocklist.configserver.dev/privacy/@general.ipset)                   |
| `Activision Gaming Network`      | Online gaming infrastructure used for multiplayer services, matchmaking, and telemetry.                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/activision.ipset)                 |
| `Ahrefs SEO Crawler`             | SEO analysis crawler used for backlink indexing and website discovery.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/ahrefs.ipset)                     |
| `AI: Claude AI Infrastructure`   | AI model service infrastructure used for conversational and API-based automation.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/ai_claude_official.ipset)         |
| `AI: OpenAI GPT Bots`            | Automated AI agents and crawler systems used for model interaction and data processing.                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/ai_openai_gpt_bot.ipset)          |
| `AI: OpenAI Chat Services`       | Interactive AI chat infrastructure used for conversational model access.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/ai_openai_gpt_chat.ipset)         |
| `AI: OpenAI Search Bots`         | Automated systems used for AI-assisted web search and content retrieval.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/ai_openai_gpt_searchbot.ipset)    |
| `Akamai CDN`                     | Global content delivery and edge security network used for high-scale traffic distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/akamai.ipset)                     |
| `Alibaba Cloud`                  | Cloud computing and infrastructure services used for hosting and distributed applications.                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/alibaba.ipset)                    |
| `Amazon AWS`                     | Global cloud infrastructure platform used for hosting, compute, and API services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/amazon_aws.ipset)                 |
| `Amazon EC2`                     | Virtual server infrastructure used for scalable cloud computing workloads.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/amazon_ec2.ipset)                 |
| `Anthropic AI`                   | AI research and model infrastructure used for conversational intelligence systems.                                                                                                                                                                                                                                                                                                                                                                                                                                                                | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/anthropic.ipset)                  |
| `Apple Bot`                      | Automated Apple crawling infrastructure used for indexing and service validation.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/apple_bot.ipset)                  |
| `Apple iCloud`                   | Cloud storage and synchronization infrastructure for Apple services and devices.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/apple_icloud.ipset)               |
| `Automattic Services`            | Web infrastructure used for WordPress.com and related hosting services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/automattic.ipset)                 |
| `Baidu Services`                 | Search and AI infrastructure used for indexing and web crawling services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/baidu.ipset)                      |
| `Bing (Microsoft)`               | Search engine and web crawler infrastructure used for indexing and ranking.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/bing.ipset)                       |
| `Blizzard Entertainment`         | Online gaming infrastructure used for multiplayer services and authentication.                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/blizzard.ipset)                   |
| `Bluehost Hosting (EIG)`         | Shared hosting infrastructure used for web hosting and domain services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/bluehost_eig.ipset)               |
| `BunnyCDN`                       | Content delivery network used for caching and global content distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/bunnycdn.ipset)                   |
| `ByteDance Network`              | Large-scale content and social platform infrastructure used for media delivery and analytics.                                                                                                                                                                                                                                                                                                                                                                                                                                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/bytedance.ipset)                  |
| `Censys Internet Scanner`        | Security research platform performing internet-wide asset discovery and scanning.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★★★    | [view](https://blocklist.configserver.dev/privacy/censys_io.ipset)                  |
| `China Broadcasting Network`     | Telecommunications and media infrastructure used for large-scale network distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                            | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_broadcasting_network.ipset) |
| `ChinaNet Backbone`              | Major ISP backbone network used for national internet traffic routing.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_chinanet.ipset)             |
| `China Mobile`                   | Large mobile network operator infrastructure providing cellular connectivity.                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_mobile.ipset)               |
| `China Network Infrastructure`   | Aggregated telecom and ISP infrastructure used across multiple national networks.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_networks.ipset)             |
| `China Mobile Network`           | Mobile carrier infrastructure used for cellular connectivity and routing.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_net_mobile.ipset)           |
| `China Telecom`                  | Major telecommunications provider used for broadband and backbone routing.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_telecom.ipset)              |
| `China Tencent Network`          | Large-scale cloud, gaming, and social infrastructure provider.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/china_tencent.ipset)              |
| `China TieTong`                  | Telecommunications infrastructure used for broadband and routing services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_tietong.ipset)              |
| `China Unicom`                   | National telecommunications provider used for mobile and broadband services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/china_unicorn.ipset)              |
| `Cloudflare Network`             | Global CDN and security infrastructure used for web protection and traffic routing.                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/cloudflare.ipset)                 |
| `CloudFront (Amazon)`            | Content delivery network used for global caching and media distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/cloudfront.ipset)                 |
| `ColoCrossing / HostPapa`        | Hosting and VPS infrastructure used for shared and dedicated server deployments.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/colocrossing_hostpapa.ipset)      |
| `Contabo VPS Hosting`            | Low-cost VPS hosting provider frequently used for automation and bulk deployments.                                                                                                                                                                                                                                                                                                                                                                                                                                                                | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/contabo_gmbh.ipset)               |
| `DigitalOcean ASN`               | Cloud VPS infrastructure widely used for application hosting and automation.                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/digitalocean_asn.ipset)           |
| `DigitalOcean Network Sources`   | Active cloud-hosted infrastructure used for compute and networking services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/digitalocean_source.ipset)        |
| `DreamHost`                      | Web hosting provider used for shared hosting and cloud services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/dreamhost.ipset)                  |
| `DuckDuckGo Crawler`             | Privacy-focused search engine crawler used for indexing web content.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/duckduckgo.ipset)                 |
| `EA / IGN Network`               | Gaming and media infrastructure used for content delivery and multiplayer services.                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/electronicarts_ign.ipset)         |
| `Facebook (Meta)`                | Social media and advertising infrastructure used for content distribution and tracking.                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/facebook.ipset)                   |
| `Fastly CDN`                     | Edge computing and content delivery network used for high-speed web distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/fastly.ipset)                     |
| `GitHub Actions`                 | CI/CD automation infrastructure used for running build and deployment pipelines.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_actions.ipset)             |
| `GitHub Actions (macOS)`         | macOS-based CI runners used for automated build and test workflows.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_actions_macos.ipset)       |
| `GitHub Infrastructure`          | Aggregated GitHub services including API, repositories, and automation systems.                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_all.ipset)                 |
| `GitHub API`                     | Programmatic access layer for GitHub services and repository management.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_api.ipset)                 |
| `GitHub Codespaces`              | Cloud-based development environments used for remote coding and execution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_codespaces.ipset)          |
| `GitHub Copilot`                 | AI-assisted code generation and autocomplete service.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_copilot.ipset)             |
| `GitHub Git Infrastructure`      | Core version control and repository hosting infrastructure.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_git.ipset)                 |
| `GitHub Webhooks`                | Event-driven automation system used for repository notifications and triggers.                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_hooks.ipset)               |
| `GitHub Importer`                | Tool used for migrating external repositories into GitHub.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_importer.ipset)            |
| `GitHub Packages`                | Package hosting and distribution service for software artifacts.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_packages.ipset)            |
| `GitHub Pages`                   | Static website hosting service integrated with GitHub repositories.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_pages.ipset)               |
| `GitHub Web Services`            | Frontend and web application infrastructure for GitHub platform access.                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/github_web.ipset)                 |
| `Google Bots`                    | Web crawling infrastructure used for search indexing and content discovery.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/google_bots.ipset)                |
| `Google Cloud Platform`          | Cloud computing infrastructure used for hosting, APIs, and distributed services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/google_cloud.ipset)               |
| `Google Core Services`           | Internal Google infrastructure used for search, analytics, and platform services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/google_core.ipset)                |
| `Huawei Network`                 | Telecommunications and cloud infrastructure used for global networking services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/huawei.ipset)                     |
| `Linode VPS Hosting`             | Cloud VPS provider used for hosting applications and server workloads.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/linode.ipset)                     |
| `Microsoft 365`                  | Cloud productivity suite infrastructure used for email, storage, and collaboration.                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/microsoft_365.ipset)              |
| `Microsoft Azure (China)`        | Region-specific Azure cloud infrastructure operating in China.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/microsoft_azure_china.ipset)      |
| `Microsoft Azure`                | Global cloud computing platform used for enterprise hosting and services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/microsoft_azure_public.ipset)     |
| `Microsoft Azure (Government)`   | Restricted Microsoft cloud environment used for US government workloads.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/microsoft_azure_usgov.ipset)      |
| `Nintendo Network`               | Gaming and console online services used for multiplayer and account access.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/nintendo.ipset)                   |
| `Oracle Cloud`                   | Enterprise cloud infrastructure used for hosting and database services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/oracle_all.ipset)                 |
| `Oracle Object Storage`          | Cloud storage service used for scalable data storage and retrieval.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/oracle_object_storage.ipset)      |
| `Oracle Cloud Infrastructure`    | Core cloud compute and networking services provided by Oracle.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/oracle_oci.ipset)                 |
| `Oracle Network Services`        | Network backbone infrastructure supporting Oracle cloud operations.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/oracle_osn.ipset)                 |
| `Pandora Streaming`              | Music streaming platform infrastructure used for audio distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/pandora.ipset)                    |
| `Pingdom Monitoring`             | Website monitoring service used for uptime and performance checks.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/pingdom.ipset)                    |
| `PirateBay Network`              | Peer-to-peer file distribution infrastructure associated with torrent indexing.                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/piratebay.ipset)                  |
| `Proton VPN`                     | Privacy-focused VPN infrastructure used for encrypted traffic routing.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/proton_vpn.ipset)                 |
| `PunkBuster Anti-Cheat`          | Gaming anti-cheat and validation infrastructure used in multiplayer environments.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/punkbuster.ipset)                 |
| `Riot Games Network`             | Online gaming infrastructure used for matchmaking and game services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/riot_games.ipset)                 |
| `RSS API Services`               | Feed aggregation and syndication services used for content distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/rssapi.ipset)                     |
| `Shadowserver Intelligence`      | Global threat intelligence and malware tracking infrastructure.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | ★★★★★    | [view](https://blocklist.configserver.dev/privacy/shadowserver.ipset)               |
| `Sony Network Services`          | Aggregated Sony online infrastructure for gaming and media services.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/sony_all.ipset)                   |
| `PlayStation Network`            | Sony gaming platform used for multiplayer services and account management.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/sony_playstation_network.ipset)   |
| `Sony User Reporting Network`    | Systems used for user reporting, telemetry, and abuse detection.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/sony_userflagged.ipset)           |
| `Steam Platform`                 | Digital game distribution and multiplayer infrastructure operated by Valve.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/steam.ipset)                      |
| `Stripe API`                     | Payment processing API used for online financial transactions.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/stripe_api.ipset)                 |
| `Stripe Infrastructure Services` | Backend payment processing and fraud detection systems.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/stripe_armada_gator.ipset)        |
| `Stripe Webhooks`                | Event notification system used for payment and transaction updates.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/privacy/stripe_webhooks.ipset)            |
| `Telegram Network`               | Messaging and media distribution infrastructure.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/telegram.ipset)                   |
| `Tumblr`                         | Social blogging platform used for media sharing and content distribution.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/tumblr.ipset)                     |
| `X (Twitter)`                    | Social media platform infrastructure used for real-time communication and content delivery.                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/twitter_x.ipset)                  |
| `Ubisoft Network`                | Online gaming infrastructure used for multiplayer services and authentication.                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/ubisoft.ipset)                    |
| `UptimeRobot Monitoring`         | Website monitoring service used for uptime tracking and alerting.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/uptimerobot.ipset)                |
| `WebPageTest`                    | Performance testing service used for analyzing website speed and behavior.                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/privacy/webpagetest.ipset)                |
| `Xfire Gaming Network`           | Legacy gaming communication and presence tracking service infrastructure.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/privacy/xfire.ipset)                      |

<br />
<br />
<br />

#### Spam

These blocklists help prevent known spam sources from accessing your server. They include IPs identified by services like Spamhaus as well as spammers targeting forums and other online platforms.

<br />

| Set              | Description                                                | Severity | View                                                           |
|------------------|------------------------------------------------------------|----------|----------------------------------------------------------------|
| `Forum Spammers` | <sub>List of known forum / blog spammers and bots</sub>    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/spam/forums.ipset)   |
| `Spamhaus`       | <sub>Bad actor IP addresses registered with Spamhaus</sub> | ★★★★⚝    | [view](https://blocklist.configserver.dev/spam/spamhaus.ipset) |

<br />
<br />
<br />

#### Internet Service Providers

These blocklists allow you to filter traffic based on Internet Service Providers (ISPs). They can be used to block or restrict access from specific networks or providers.

| Set                                      | Description                                                                                             | Severity | View                                                                                  |
|------------------------------------------|---------------------------------------------------------------------------------------------------------|----------|---------------------------------------------------------------------------------------|
| `AOL`                                    | IP ranges associated with AOL residential and legacy internet service infrastructure.                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/aol.ipset)                              |
| `AT&T`                                   | Residential, wireless, and broadband IP ranges operated by AT&T internet services.                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/isp/att.ipset)                              |
| `Cablevision`                            | Customer broadband networks and infrastructure historically associated with Cablevision services.       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/cablevision.ipset)                      |
| `Charter / Spectrum / Time Warner Cable` | Consumer and business broadband IP ranges operated by Charter Communications and Spectrum services.     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/isp/charter_spectrum_timewarnercable.ipset) |
| `Comcast`                                | Residential and commercial Comcast Xfinity broadband subscriber networks and infrastructure.            | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/isp/comcast.ipset)                          |
| `Cox Communications`                     | Broadband customer IP ranges and network infrastructure operated by Cox Communications.                 | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/cox_communications.ipset)               |
| `Embarq`                                 | Legacy telecommunications and broadband infrastructure formerly operated under Embarq networks.         | ★⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/embarq.ipset)                           |
| `Frontier Communications`                | Consumer and enterprise broadband infrastructure operated by Frontier Communications.                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/frontier_communications.ipset)          |
| `Qwest`                                  | Legacy Qwest broadband and telecommunications IP address ranges.                                        | ★⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/qwest.ipset)                            |
| `Qwest / CenturyLink`                    | Residential and business internet infrastructure associated with CenturyLink and legacy Qwest services. | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/qwest_centurylink.ipset)                |
| `SpaceX Starlink`                        | Satellite-based broadband subscriber networks operated through the Starlink internet service.           | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/isp/spacex_starlink.ipset)                  |
| `Sprint`                                 | Legacy mobile carrier and wireless broadband IP infrastructure associated with Sprint networks.         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/sprint.ipset)                           |
| `Suddenlink / Altice / Optimum`          | Broadband subscriber and network infrastructure operated under Altice and Optimum services.             | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/isp/suddenlink_altice_optimum.ipset)        |
| `Verizon`                                | Residential, mobile, and enterprise internet infrastructure operated by Verizon Communications.         | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/isp/verizon.ipset)                          |

<br />
<br />
<br />

#### Transmission (BitTorrent Client)

This section includes blocklists which you can import into the [bittorrent client Transmission](https://transmissionbt.com/).

<br />

- In this repo, copy the direct URL to the Transmission blocklist, provided below:
    - https://github.com/ConfigServerApps/service-blocklists/raw/main/blocklists/transmission/blocklist.gz
- Open your Transmission application; depending on the version you run, do ONE of the follow two choices:
    - Paste the link to **Transmission** › `Settings` › `Peers` › `Blocklist`
    - Paste the link to **Transmission** › `Edit` › `Preferences` › `Privacy` › `Enable Blocklist`

<br />

| Set                        | Description                                                                             | Severity | View                                                                    | Website                             |
|----------------------------|-----------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------|-------------------------------------|
| `Transmission (Primary 1)` | A large blocklist for the BitTorrent client [Transmission](https://transmissionbt.com/) | ★★★★★    | [view](https://blocklist.configserver.dev/transmission/blocklist.ipset) | [view](https://transmissionbt.com/) |

<br />
<br />
<br />

#### Geographical Databases

These blocklists let you control which geographical locations can access your server. They can be used as either a whitelist or a blacklist and include both **continents** and **countries**.  

All data from these blocklists are populated by services such as [GeoLite2](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data/) and [Ip2Location](https://lite.ip2location.com/database-download).

<br />

##### Summary

| Set                    | Description                                                                                               | Severity   | View                                                                  |
|------------------------|-----------------------------------------------------------------------------------------------------------|------------|-----------------------------------------------------------------------|
| `GeoLite2 Database`    | <sub>Lists IPs by continent and country from GeoLite2 database. Contains both IPv4 and IPv6 subnets</sub> | ★★★★★    | [view](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data/) |
| `Ip2Location Database` | <sub>Coming soon</sub>                                                                                    | ★★★★★    | [view](https://lite.ip2location.com/database-download)                |

<br />

##### Continents

These blocklists let you control which geographical locations can access your server. They can be used as either a whitelist or a blacklist and include both **continents** and **countries**.  

All data is sourced directly from the GeoLite2 Database.

| Set             | Description                                                                                             | Severity  | View                                                                                     |
|-----------------|---------------------------------------------------------------------------------------------------------|-----------|------------------------------------------------------------------------------------------|
| `Africa`        | IP ranges geographically assigned to countries and territories within the African continent.            | ★★⚝⚝⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_africa.ipset)        |
| `Antarctica`    | IP ranges associated with research stations, satellite links, and infrastructure located in Antarctica. | ★⚝⚝⚝⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_antartica.ipset)     |
| `Asia`          | IP ranges geographically assigned to countries and territories throughout the Asian continent.          | ★★★★⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_asia.ipset)          |
| `Europe`        | IP ranges geographically assigned to countries and territories within Europe.                           | ★★★⚝⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_europe.ipset)        |
| `North America` | IP ranges geographically assigned to countries and territories across North America.                    | ★★★⚝⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_north_america.ipset) |
| `Oceania`       | IP ranges associated with countries, territories, and island regions located throughout Oceania.        | ★★⚝⚝⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_oceania.ipset)       |
| `South America` | IP ranges geographically assigned to countries and territories within South America.                    | ★★⚝⚝⚝   | [view](https://blocklist.configserver.dev/geolite/country/continent_south_america.ipset) |

<br />

##### Countries

These blocklists let you control which geographical locations can access your server. They can be used as either a whitelist or a blacklist and include both **continents** and **countries**.  

All data is sourced directly from the GeoLite2 Database.

| Set                                                          | Description                                  | Severity   | View                                                                                                  |
|--------------------------------------------------------------|----------------------------------------------|------------|-------------------------------------------------------------------------------------------------------|
| `country_afghanistan.ipset`                                  | Afghanistan                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_afghanistan.ipset)                                  |
| `country_aland_islands.ipset`                                | Aland Islands                                | ★⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_aland_islands.ipset)                                |
| `country_albania.ipset`                                      | Albania                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_albania.ipset)                                      |
| `country_algeria.ipset`                                      | Algeria                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_algeria.ipset)                                      |
| `country_american_samoa.ipset`                               | American Samoa                               | ★⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_american_samoa.ipset)                               |
| `country_andorra.ipset`                                      | Andorra                                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_andorra.ipset)                                      |
| `country_angola.ipset`                                       | Angola                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_angola.ipset)                                       |
| `country_anguilla.ipset`                                     | Anguilla                                     | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_anguilla.ipset)                                     |
| `country_antarctica.ipset`                                   | Antarctica                                   | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_antarctica.ipset)                                   |
| `country_antigua_barbuda.ipset`                              | Antigua and Barbuda                          | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_antigua_barbuda.ipset)                              |
| `country_argentina.ipset`                                    | Argentina                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_argentina.ipset)                                    |
| `country_armenia.ipset`                                      | Armenia                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_armenia.ipset)                                      |
| `country_aruba.ipset`                                        | Aruba                                        | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_aruba.ipset)                                        |
| `country_australia.ipset`                                    | Australia                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_australia.ipset)                                    |
| `country_austria.ipset`                                      | Austria                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_austria.ipset)                                      |
| `country_azerbaijan.ipset`                                   | Azerbaijan                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_azerbaijan.ipset)                                   |
| `country_bahamas.ipset`                                      | The Bahamas                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bahamas.ipset)                                      |
| `country_bahrain.ipset`                                      | Bahrain                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bahrain.ipset)                                      |
| `country_bangladesh.ipset`                                   | Bangladesh                                   | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_bangladesh.ipset)                                   |
| `country_barbados.ipset`                                     | Barbados                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_barbados.ipset)                                     |
| `country_belarus.ipset`                                      | Belarus                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_belarus.ipset)                                      |
| `country_belgium.ipset`                                      | Belgium                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_belgium.ipset)                                      |
| `country_belize.ipset`                                       | Belize                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_belize.ipset)                                       |
| `country_benin.ipset`                                        | Benin                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_benin.ipset)                                        |
| `country_bermuda.ipset`                                      | Bermuda                                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bermuda.ipset)                                      |
| `country_bhutan.ipset`                                       | Bhutan                                       | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bhutan.ipset)                                       |
| `country_bolivia.ipset`                                      | Bolivia                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bolivia.ipset)                                      |
| `country_bonaire_sint_eustatius_saba.ipset`                  | Bonaire, Sint Eustatius, and Saba            | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bonaire_sint_eustatius_saba.ipset)                  |
| `country_bosnia_herzegovina.ipset`                           | Bosnia and Herzegovina                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_bosnia_herzegovina.ipset)                           |
| `country_botswana.ipset`                                     | Botswana                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_botswana.ipset)                                     |
| `country_bouvet_island.ipset`                                | Bouvet Island                                | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bouvet_island.ipset)                                |
| `country_brazil.ipset`                                       | Brazil                                       | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_brazil.ipset)                                       |
| `country_british_indian_ocean_territory.ipset`               | British Indian Ocean Territory               | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_british_indian_ocean_territory.ipset)               |
| `country_british_virgin_islands.ipset`                       | British Virgin Islands                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_british_virgin_islands.ipset)                       |
| `country_brunei_darussalam.ipset`                            | Brunei                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_brunei_darussalam.ipset)                            |
| `country_bulgaria.ipset`                                     | Bulgaria                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_bulgaria.ipset)                                     |
| `country_burkina_faso.ipset`                                 | Burkina Faso                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_burkina_faso.ipset)                                 |
| `country_burundi.ipset`                                      | Burundi                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_burundi.ipset)                                      |
| `country_cambodia.ipset`                                     | Cambodia                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_cambodia.ipset)                                     |
| `country_cameroon.ipset`                                     | Cameroon                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_cameroon.ipset)                                     |
| `country_canada.ipset`                                       | Canada                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_canada.ipset)                                       |
| `country_cape_verde.ipset`                                   | Cape Verde                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_cape_verde.ipset)                                   |
| `country_cayman_islands.ipset`                               | Cayman Islands                               | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_cayman_islands.ipset)                               |
| `country_cc.ipset`                                           | Cocos (Keeling) Islands                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_cc.ipset)                                           |
| `country_central_african_republic.ipset`                     | Central African Republic                     | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_central_african_republic.ipset)                     |
| `country_chad.ipset`                                         | Chad                                         | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_chad.ipset)                                         |
| `country_chile.ipset`                                        | Chile                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_chile.ipset)                                        |
| `country_china.ipset`                                        | China                                        | ★★★★★    | [view](https://blocklist.configserver.dev/country_china.ipset)                                        |
| `country_christmas_island.ipset`                             | Christmas Island                             | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_christmas_island.ipset)                             |
| `country_colombia.ipset`                                     | Colombia                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_colombia.ipset)                                     |
| `country_comoros.ipset`                                      | Comoros                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_comoros.ipset)                                      |
| `country_congo.ipset`                                        | Congo                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_congo.ipset)                                        |
| `country_cook_islands.ipset`                                 | Cook Islands                                 | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_cook_islands.ipset)                                 |
| `country_costa_rica.ipset`                                   | Costa Rica                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_costa_rica.ipset)                                   |
| `country_cote_divoire.ipset`                                 | Côte d'Ivoire                                | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_cote_divoire.ipset)                                 |
| `country_croatia.ipset`                                      | Croatia                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_croatia.ipset)                                      |
| `country_cuba.ipset`                                         | Cuba                                         | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_cuba.ipset)                                         |
| `country_curacao.ipset`                                      | Curaçao                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_curacao.ipset)                                      |
| `country_cyprus.ipset`                                       | Cyprus                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_cyprus.ipset)                                       |
| `country_czech_republic.ipset`                               | Czech Republic                               | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_czech_republic.ipset)                               |
| `country_democratic_republic_congo.ipset`                    | Democratic Republic of the Congo             | ★★★★★    | [view](https://blocklist.configserver.dev/country_democratic_republic_congo.ipset)                    |
| `country_denmark.ipset`                                      | Denmark                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_denmark.ipset)                                      |
| `country_djibouti.ipset`                                     | Djibouti                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_djibouti.ipset)                                     |
| `country_dominica.ipset`                                     | Dominica                                     | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_dominica.ipset)                                     |
| `country_dominican_republic.ipset`                           | Dominican Republic                           | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_dominican_republic.ipset)                           |
| `country_ecuador.ipset`                                      | Ecuador                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_ecuador.ipset)                                      |
| `country_egypt.ipset`                                        | Egypt                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_egypt.ipset)                                        |
| `country_el_salvador.ipset`                                  | El Salvador                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_el_salvador.ipset)                                  |
| `country_equatorial_guinea.ipset`                            | Equatorial Guinea                            | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_equatorial_guinea.ipset)                            |
| `country_eritrea.ipset`                                      | Eritrea                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_eritrea.ipset)                                      |
| `country_estonia.ipset`                                      | Estonia                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_estonia.ipset)                                      |
| `country_eswatini.ipset`                                     | Eswatini                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_eswatini.ipset)                                     |
| `country_ethiopia.ipset`                                     | Ethiopia                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_ethiopia.ipset)                                     |
| `country_europe.ipset`                                       | Europe                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_europe.ipset)                                       |
| `country_falkland_islands_malvinas.ipset`                    | Falkland Islands (Malvinas)                  | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_falkland_islands_malvinas.ipset)                    |
| `country_faroe_islands.ipset`                                | Faroe Islands                                | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_faroe_islands.ipset)                                |
| `country_fiji.ipset`                                         | Fiji                                         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_fiji.ipset)                                         |
| `country_finland.ipset`                                      | Finland                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_finland.ipset)                                      |
| `country_france.ipset`                                       | France                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_france.ipset)                                       |
| `country_french_guiana.ipset`                                | French Guiana                                | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_french_guiana.ipset)                                |
| `country_french_polynesia.ipset`                             | French Polynesia                             | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_french_polynesia.ipset)                             |
| `country_french_southern_territories.ipset`                  | French Southern Territories                  | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_french_southern_territories.ipset)                  |
| `country_gabon.ipset`                                        | Gabon                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_gabon.ipset)                                        |
| `country_gambia.ipset`                                       | Gambia                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_gambia.ipset)                                       |
| `country_georgia.ipset`                                      | Georgia                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_georgia.ipset)                                      |
| `country_germany.ipset`                                      | Germany                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_germany.ipset)                                      |
| `country_ghana.ipset`                                        | Ghana                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_ghana.ipset)                                        |
| `country_gibraltar.ipset`                                    | Gibraltar                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_gibraltar.ipset)                                    |
| `country_great_britain.ipset`                                | Great Britain                                | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_great_britain.ipset)                                |
| `country_greece.ipset`                                       | Greece                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_greece.ipset)                                       |
| `country_greenland.ipset`                                    | Greenland                                    | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_greenland.ipset)                                    |
| `country_grenada.ipset`                                      | Grenada                                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_grenada.ipset)                                      |
| `country_guadeloupe.ipset`                                   | Guadeloupe                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_guadeloupe.ipset)                                   |
| `country_guam.ipset`                                         | Guam                                         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_guam.ipset)                                         |
| `country_guatemala.ipset`                                    | Guatemala                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_guatemala.ipset)                                    |
| `country_guernsey.ipset`                                     | Guernsey                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_guernsey.ipset)                                     |
| `country_guineabissau.ipset`                                 | Guinea-Bissau                                | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_guineabissau.ipset)                                 |
| `country_guinea.ipset`                                       | Guinea                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_guinea.ipset)                                       |
| `country_guyana.ipset`                                       | Guyana                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_guyana.ipset)                                       |
| `country_haiti.ipset`                                        | Haiti                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_haiti.ipset)                                        |
| `country_heard_island_and_mcdonald_islands.ipset`            | Heard Island and McDonald Islands            | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_heard_island_and_mcdonald_islands.ipset)            |
| `country_honduras.ipset`                                     | Honduras                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_honduras.ipset)                                     |
| `country_hong_kong.ipset`                                    | Hong Kong                                    | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_hong_kong.ipset)                                    |
| `country_hungary.ipset`                                      | Hungary                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_hungary.ipset)                                      |
| `country_iceland.ipset`                                      | Iceland                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_iceland.ipset)                                      |
| `country_india.ipset`                                        | India                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_india.ipset)                                        |
| `country_indonesia.ipset`                                    | Indonesia                                    | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_indonesia.ipset)                                    |
| `country_iran.ipset`                                         | Iran                                         | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_iran.ipset)                                         |
| `country_iraq.ipset`                                         | Iraq                                         | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_iraq.ipset)                                         |
| `country_ireland.ipset`                                      | Ireland                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_ireland.ipset)                                      |
| `country_isle_of_man.ipset`                                  | Isle of Man                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_isle_of_man.ipset)                                  |
| `country_israel.ipset`                                       | Israel                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_israel.ipset)                                       |
| `country_italy.ipset`                                        | Italy                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_italy.ipset)                                        |
| `country_jamaica.ipset`                                      | Jamaica                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_jamaica.ipset)                                      |
| `country_japan.ipset`                                        | Japan                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_japan.ipset)                                        |
| `country_jersey.ipset`                                       | Jersey                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_jersey.ipset)                                       |
| `country_jordan.ipset`                                       | Jordan                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_jordan.ipset)                                       |
| `country_kazakhstan.ipset`                                   | Kazakhstan                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_kazakhstan.ipset)                                   |
| `country_kenya.ipset`                                        | Kenya                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_kenya.ipset)                                        |
| `country_kiribati.ipset`                                     | Kiribati                                     | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_kiribati.ipset)                                     |
| `country_kosovo.ipset`                                       | Kosovo                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_kosovo.ipset)                                       |
| `country_kuwait.ipset`                                       | Kuwait                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_kuwait.ipset)                                       |
| `country_kyrgyzstan.ipset`                                   | Kyrgyzstan                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_kyrgyzstan.ipset)                                   |
| `country_laos.ipset`                                         | Laos                                         | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_laos.ipset)                                         |
| `country_latvia.ipset`                                       | Latvia                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_latvia.ipset)                                       |
| `country_lebanon.ipset`                                      | Lebanon                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_lebanon.ipset)                                      |
| `country_lesotho.ipset`                                      | Lesotho                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_lesotho.ipset)                                      |
| `country_liberia.ipset`                                      | Liberia                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_liberia.ipset)                                      |
| `country_libya.ipset`                                        | Libya                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_libya.ipset)                                        |
| `country_liechtenstein.ipset`                                | Liechtenstein                                | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_liechtenstein.ipset)                                |
| `country_lithuania.ipset`                                    | Lithuania                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_lithuania.ipset)                                    |
| `country_luxembourg.ipset`                                   | Luxembourg                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_luxembourg.ipset)                                   |
| `country_macedonia_republic.ipset`                           | Macedonia                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_macedonia_republic.ipset)                           |
| `country_madagascar.ipset`                                   | Madagascar                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_madagascar.ipset)                                   |
| `country_malawi.ipset`                                       | Malawi                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_malawi.ipset)                                       |
| `country_malaysia.ipset`                                     | Malaysia                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_malaysia.ipset)                                     |
| `country_maldives.ipset`                                     | Maldives                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_maldives.ipset)                                     |
| `country_mali.ipset`                                         | Mali                                         | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_mali.ipset)                                         |
| `country_malta.ipset`                                        | Malta                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_malta.ipset)                                        |
| `country_marshall_islands.ipset`                             | Marshall Islands                             | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_marshall_islands.ipset)                             |
| `country_martinique.ipset`                                   | Martinique                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_martinique.ipset)                                   |
| `country_mauritania.ipset`                                   | Mauritania                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_mauritania.ipset)                                   |
| `country_mauritius.ipset`                                    | Mauritius                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_mauritius.ipset)                                    |
| `country_mayotte.ipset`                                      | Mayotte                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_mayotte.ipset)                                      |
| `country_mexico.ipset`                                       | Mexico                                       | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_mexico.ipset)                                       |
| `country_micronesia.ipset`                                   | Micronesia                                   | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_micronesia.ipset)                                   |
| `country_monaco.ipset`                                       | Monaco                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_monaco.ipset)                                       |
| `country_mongolia.ipset`                                     | Mongolia                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_mongolia.ipset)                                     |
| `country_montenegro.ipset`                                   | Montenegro                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_montenegro.ipset)                                   |
| `country_montserrat.ipset`                                   | Montserrat                                   | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_montserrat.ipset)                                   |
| `country_morocco.ipset`                                      | Morocco                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_morocco.ipset)                                      |
| `country_mozambique.ipset`                                   | Mozambique                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_mozambique.ipset)                                   |
| `country_myanmar.ipset`                                      | Myanmar                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_myanmar.ipset)                                      |
| `country_namibia.ipset`                                      | Namibia                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_namibia.ipset)                                      |
| `country_nauru.ipset`                                        | Nauru                                        | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_nauru.ipset)                                        |
| `country_nepal.ipset`                                        | Nepal                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_nepal.ipset)                                        |
| `country_netherlands.ipset`                                  | Netherlands                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_netherlands.ipset)                                  |
| `country_new_caledonia.ipset`                                | New Caledonia                                | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_new_caledonia.ipset)                                |
| `country_new_zealand.ipset`                                  | New Zealand                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_new_zealand.ipset)                                  |
| `country_nicaragua.ipset`                                    | Nicaragua                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_nicaragua.ipset)                                    |
| `country_nigeria.ipset`                                      | Nigeria                                      | ★★★★★    | [view](https://blocklist.configserver.dev/country_nigeria.ipset)                                      |
| `country_niger.ipset`                                        | Niger                                        | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_niger.ipset)                                        |
| `country_niue.ipset`                                         | Niue                                         | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_niue.ipset)                                         |
| `country_norfolk_island.ipset`                               | Norfolk Island                               | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_norfolk_island.ipset)                               |
| `country_northern_mariana_islands.ipset`                     | Northern Mariana Islands                     | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_northern_mariana_islands.ipset)                     |
| `country_north_korea.ipset`                                  | North Korea                                  | ★★★★★    | [view](https://blocklist.configserver.dev/country_north_korea.ipset)                                  |
| `country_norway.ipset`                                       | Norway                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_norway.ipset)                                       |
| `country_oman.ipset`                                         | Oman                                         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_oman.ipset)                                         |
| `country_pakistan.ipset`                                     | Pakistan                                     | ★★★★★    | [view](https://blocklist.configserver.dev/country_pakistan.ipset)                                     |
| `country_palau.ipset`                                        | Palau                                        | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_palau.ipset)                                        |
| `country_palestine.ipset`                                    | Palestine                                    | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_palestine.ipset)                                    |
| `country_panama.ipset`                                       | Panama                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_panama.ipset)                                       |
| `country_papua_new_guinea.ipset`                             | Papua New Guinea                             | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_papua_new_guinea.ipset)                             |
| `country_paraguay.ipset`                                     | Paraguay                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_paraguay.ipset)                                     |
| `country_peru.ipset`                                         | Peru                                         | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_peru.ipset)                                         |
| `country_philippines.ipset`                                  | Philippines                                  | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_philippines.ipset)                                  |
| `country_pitcairn.ipset`                                     | Pitcairn Islands                             | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_pitcairn.ipset)                                     |
| `country_poland.ipset`                                       | Poland                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_poland.ipset)                                       |
| `country_portugal.ipset`                                     | Portugal                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_portugal.ipset)                                     |
| `country_puerto_rico.ipset`                                  | Puerto Rico                                  | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_puerto_rico.ipset)                                  |
| `country_qatar.ipset`                                        | Qatar                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_qatar.ipset)                                        |
| `country_republic_moldova.ipset`                             | Moldova                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_republic_moldova.ipset)                             |
| `country_reunion.ipset`                                      | Réunion                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_reunion.ipset)                                      |
| `country_romania.ipset`                                      | Romania                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_romania.ipset)                                      |
| `country_russia.ipset`                                       | Russia                                       | ★★★★★    | [view](https://blocklist.configserver.dev/country_russia.ipset)                                       |
| `country_rwanda.ipset`                                       | Rwanda                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_rwanda.ipset)                                       |
| `country_saint_barthelemy.ipset`                             | Saint Barthélemy                             | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_barthelemy.ipset)                             |
| `country_saint_helena.ipset`                                 | Saint Helena                                 | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_helena.ipset)                                 |
| `country_saint_kitts_nevis.ipset`                            | Saint Kitts and Nevis                        | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_kitts_nevis.ipset)                            |
| `country_saint_lucia.ipset`                                  | Saint Lucia                                  | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_lucia.ipset)                                  |
| `country_saint_martin_north.ipset`                           | Saint Martin (North)                         | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_martin_north.ipset)                           |
| `country_saint_pierre_miquelon.ipset`                        | Saint Pierre and Miquelon                    | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_pierre_miquelon.ipset)                        |
| `country_saint_vincent_grenadines.ipset`                     | Saint Vincent and the Grenadines             | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_saint_vincent_grenadines.ipset)                     |
| `country_samoa.ipset`                                        | Samoa                                        | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_samoa.ipset)                                        |
| `country_san_marino.ipset`                                   | San Marino                                   | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_san_marino.ipset)                                   |
| `country_sao_tome_principe.ipset`                            | São Tomé and Príncipe                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_sao_tome_principe.ipset)                            |
| `country_saudi_arabia.ipset`                                 | Saudi Arabia                                 | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_saudi_arabia.ipset)                                 |
| `country_senegal.ipset`                                      | Senegal                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_senegal.ipset)                                      |
| `country_serbia.ipset`                                       | Serbia                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_serbia.ipset)                                       |
| `country_seychelles.ipset`                                   | Seychelles                                   | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_seychelles.ipset)                                   |
| `country_sierra_leone.ipset`                                 | Sierra Leone                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_sierra_leone.ipset)                                 |
| `country_singapore.ipset`                                    | Singapore                                    | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_singapore.ipset)                                    |
| `country_sint_maarten_south.ipset`                           | Sint Maarten (South)                         | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_sint_maarten_south.ipset)                           |
| `country_slovakia.ipset`                                     | Slovakia                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_slovakia.ipset)                                     |
| `country_slovenia.ipset`                                     | Slovenia                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_slovenia.ipset)                                     |
| `country_solomon_islands.ipset`                              | Solomon Islands                              | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_solomon_islands.ipset)                              |
| `country_somalia.ipset`                                      | Somalia                                      | ★★★★★    | [view](https://blocklist.configserver.dev/country_somalia.ipset)                                      |
| `country_south_africa.ipset`                                 | South Africa                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_south_africa.ipset)                                 |
| `country_south_georgia_and_the_south_sandwich_islands.ipset` | South Georgia and the South Sandwich Islands | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_south_georgia_and_the_south_sandwich_islands.ipset) |
| `country_south_korea.ipset`                                  | South Korea                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_south_korea.ipset)                                  |
| `country_south_sudan.ipset`                                  | South Sudan                                  | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_south_sudan.ipset)                                  |
| `country_spain.ipset`                                        | Spain                                        | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_spain.ipset)                                        |
| `country_sri_lanka.ipset`                                    | Sri Lanka                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_sri_lanka.ipset)                                    |
| `country_sudan.ipset`                                        | Sudan                                        | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_sudan.ipset)                                        |
| `country_suriname.ipset`                                     | Suriname                                     | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_suriname.ipset)                                     |
| `country_svalbard_jan_mayen.ipset`                           | Svalbard and Jan Mayen                       | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_svalbard_jan_mayen.ipset)                           |
| `country_sweden.ipset`                                       | Sweden                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_sweden.ipset)                                       |
| `country_switzerland.ipset`                                  | Switzerland                                  | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_switzerland.ipset)                                  |
| `country_syria.ipset`                                        | Syria                                        | ★★★★★    | [view](https://blocklist.configserver.dev/country_syria.ipset)                                        |
| `country_taiwan.ipset`                                       | Taiwan                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_taiwan.ipset)                                       |
| `country_tajikistan.ipset`                                   | Tajikistan                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_tajikistan.ipset)                                   |
| `country_tanzania.ipset`                                     | Tanzania                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_tanzania.ipset)                                     |
| `country_thailand.ipset`                                     | Thailand                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_thailand.ipset)                                     |
| `country_timorleste.ipset`                                   | Timor-Leste                                  | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_timorleste.ipset)                                   |
| `country_togo.ipset`                                         | Togo                                         | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_togo.ipset)                                         |
| `country_tokelau.ipset`                                      | Tokelau                                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_tokelau.ipset)                                      |
| `country_tonga.ipset`                                        | Tonga                                        | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_tonga.ipset)                                        |
| `country_trinidad_tobago.ipset`                              | Trinidad and Tobago                          | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_trinidad_tobago.ipset)                              |
| `country_tunisia.ipset`                                      | Tunisia                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_tunisia.ipset)                                      |
| `country_turkey.ipset`                                       | Turkey                                       | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_turkey.ipset)                                       |
| `country_turkmenistan.ipset`                                 | Turkmenistan                                 | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_turkmenistan.ipset)                                 |
| `country_turks_caicos_islands.ipset`                         | Turks and Caicos Islands                     | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_turks_caicos_islands.ipset)                         |
| `country_tuvalu.ipset`                                       | Tuvalu                                       | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_tuvalu.ipset)                                       |
| `country_uganda.ipset`                                       | Uganda                                       | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_uganda.ipset)                                       |
| `country_ukraine.ipset`                                      | Ukraine                                      | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_ukraine.ipset)                                      |
| `country_united_arab_emirates.ipset`                         | United Arab Emirates                         | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_united_arab_emirates.ipset)                         |
| `country_united_states.ipset`                                | United States                                | ★★★★⚝    | [view](https://blocklist.configserver.dev/country_united_states.ipset)                                |
| `country_united_states_minor_outlying_islands.ipset`         | US Minor Outlying Islands                    | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_united_states_minor_outlying_islands.ipset)         |
| `country_united_states_virgin_islands.ipset`                 | US Virgin Islands                            | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_united_states_virgin_islands.ipset)                 |
| `country_uruguay.ipset`                                      | Uruguay                                      | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_uruguay.ipset)                                      |
| `country_uzbekistan.ipset`                                   | Uzbekistan                                   | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_uzbekistan.ipset)                                   |
| `country_vanuatu.ipset`                                      | Vanuatu                                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_vanuatu.ipset)                                      |
| `country_vatican_city_holy_see.ipset`                        | Vatican City / Holy See                      | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_vatican_city_holy_see.ipset)                        |
| `country_venezuela.ipset`                                    | Venezuela                                    | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_venezuela.ipset)                                    |
| `country_vietnam.ipset`                                      | Vietnam                                      | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_vietnam.ipset)                                      |
| `country_wallis_futuna.ipset`                                | Wallis and Futuna                            | ⚝⚝⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_wallis_futuna.ipset)                                |
| `country_western_sahara.ipset`                               | Western Sahara                               | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_western_sahara.ipset)                               |
| `country_yemen.ipset`                                        | Yemen                                        | ★★★★★    | [view](https://blocklist.configserver.dev/country_yemen.ipset)                                        |
| `country_zambia.ipset`                                       | Zambia                                       | ★★⚝⚝⚝    | [view](https://blocklist.configserver.dev/country_zambia.ipset)                                       |
| `country_zimbabwe.ipset`                                     | Zimbabwe                                     | ★★★⚝⚝    | [view](https://blocklist.configserver.dev/country_zimbabwe.ipset)                                     |

<br />
<br />
<br />

### Third-Party Blocklists

The blocklists within this category are sourced from trusted third-party threat intelligence and reputation providers. These external feeds aggregate data from intrusion 
detection systems, abuse reports, malware analysis platforms, honeypots, spam traps, and global monitoring networks to identify IP addresses associated with malicious, 
abusive, or suspicious activity.

Because these blocklists are maintained externally, the contents may change frequently and can vary in accuracy, aggressiveness, and scope depending on the provider. While 
we validate and format these lists for compatibility and reliability, the underlying IP intelligence and classifications are managed by the original upstream maintainers.

| Blocklist                                                                                                             | Description                                                                                                                                                                 | Severity | View                                                                                      |
|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------|
| [BBcan177 MS1 Reputation Feed](https://blocklist.configserver.dev/3rdparty/BBcan177/ms1.ipset)                        | Community-maintained abuse and intrusion reputation feed identifying malicious IPs observed engaging in scanning, brute-force, and exploit activity across public services. | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/BBcan177/ms1.ipset)                    |
| [BBcan177 MS3 High-Risk Feed](https://blocklist.configserver.dev/3rdparty/BBcan177/ms3.ipset)                         | Expanded BBcan177 threat feed focusing on higher-confidence malicious infrastructure, including repeated attackers and persistent scanning sources.                         | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/BBcan177/ms3.ipset)                    |
| [MyIP.ms Global Blocklist](https://blocklist.configserver.dev/3rdparty/Myip.ms/blocklist.ipset)                       | Aggregated IP reputation dataset derived from hosting intelligence and user reports identifying suspicious hosting providers and abusive networks.                          | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/Myip.ms/blocklist.ipset)               |
| [AlienVault Bad Reputation](https://blocklist.configserver.dev/3rdparty/alienvault/bad_reputation.ipset)              | Threat intelligence feed identifying IPs associated with malware distribution, botnets, scanning activity, and other malicious behavior.                                    | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/alienvault/bad_reputation.ipset)       |
| [BinaryDefense Blocklist](https://blocklist.configserver.dev/3rdparty/binarydefense/blocklist.ipset)                  | Actively maintained security blocklist focused on malware, brute-force attackers, exploit attempts, and known malicious infrastructure.                                     | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/binarydefense/blocklist.ipset)         |
| [Bitwire Inbound Threat Feed](https://blocklist.configserver.dev/3rdparty/bitwire/inbound.ipset)                      | Inbound traffic reputation list identifying abusive sources targeting exposed services and infrastructure.                                                                  | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/bitwire/inbound.ipset)                 |
| [Bitwire Outbound Threat Feed](https://blocklist.configserver.dev/3rdparty/bitwire/outbound.ipset)                    | Outbound reputation dataset tracking compromised systems and malicious hosting activity used for attacks.                                                                   | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/bitwire/outbound.ipset)                |
| [Blocklist.de Combined Feed](https://blocklist.configserver.dev/3rdparty/blocklist.de/all.ipset)                      | Aggregated abusive IP feed covering SSH, mail, web, and bot attacks sourced from intrusion detection systems.                                                               | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/all.ipset)                |
| [Blocklist.de Apache Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_apache.ipset)          | IP addresses involved in automated attacks and exploitation attempts targeting Apache web servers.                                                                          | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_apache.ipset)     |
| [Blocklist.de Bot Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_bots.ipset)               | Known bot networks engaging in scanning, scraping, and automated abuse of public services.                                                                                  | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_bots.ipset)       |
| [Blocklist.de Brute Force Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_bruteforce.ipset) | IPs repeatedly attempting password brute-force attacks against exposed authentication services.                                                                             | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_bruteforce.ipset) |
| [Blocklist.de FTP Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_ftp.ipset)                | Malicious sources targeting FTP services with credential stuffing and brute-force attempts.                                                                                 | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_ftp.ipset)        |
| [Blocklist.de IMAP Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_imap.ipset)              | IPs observed attempting unauthorized access to email systems via IMAP authentication attacks.                                                                               | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_imap.ipset)       |
| [Blocklist.de IRC Botnets](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_ircbot.ipset)             | Known IRC-based botnet infrastructure used for command-and-control and coordinated malicious activity.                                                                      | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_ircbot.ipset)     |
| [Blocklist.de Long-Term Attackers](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_longterm.ipset)   | Persistent malicious IPs repeatedly involved in abuse, scanning, and exploit attempts over extended periods.                                                                | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_longterm.ipset)   |
| [Blocklist.de Mail Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_mail.ipset)              | IP addresses targeting mail servers with spam, relay abuse, and credential attacks.                                                                                         | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_mail.ipset)       |
| [Blocklist.de SIP Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_sip.ipset)                | VoIP and SIP-based attack sources used for fraud, scanning, and unauthorized call attempts.                                                                                 | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_sip.ipset)        |
| [Blocklist.de SSH Attacks](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_ssh.ipset)                | Widely observed SSH brute-force and credential stuffing sources targeting exposed servers.                                                                                  | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/blocklist.de/attacks_ssh.ipset)        |
| [Botvrij Threat Intelligence IOC](https://blocklist.configserver.dev/3rdparty/botvrij/threats_ioc.ipset)              | Indicator-of-compromise feed identifying malware infrastructure, botnets, and active threat campaigns.                                                                      | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/botvrij/threats_ioc.ipset)             |
| [BruteForceBlocker Feed](https://blocklist.configserver.dev/3rdparty/bruteforceblocker/blocklist.ipset)               | Dedicated list of IPs repeatedly attempting automated password guessing and authentication abuse.                                                                           | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/bruteforceblocker/blocklist.ipset)     |
| [DShield Global Attack Feed](https://blocklist.configserver.dev/3rdparty/dshield/blocklist.ipset)                     | Internet-wide attack telemetry aggregated from intrusion sensors identifying scanning and exploit attempts.                                                                 | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/dshield/blocklist.ipset)               |
| [DShield Recommended Blocklist](https://blocklist.configserver.dev/3rdparty/dshield/recommended.ipset)                | Curated subset of DShield data highlighting high-confidence malicious and abusive IP addresses.                                                                             | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/dshield/recommended.ipset)             |
| [FireHOL Abusers (1 Day)](https://blocklist.configserver.dev/3rdparty/firehol/abusers_1d.ipset)                       | Recent abusive IPs observed within 24 hours performing scanning, brute-force, or exploit attempts.                                                                          | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/abusers_1d.ipset)              |
| [FireHOL Abusers (30 Day)](https://blocklist.configserver.dev/3rdparty/firehol/abusers_30d.ipset)                     | Aggregated abusive sources observed over a 30-day window with repeated malicious behavior.                                                                                  | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/abusers_30d.ipset)             |
| [FireHOL Anonymous Proxies](https://blocklist.configserver.dev/3rdparty/firehol/anonymous.ipset)                      | Proxy and anonymization services commonly used to mask identity during scanning or abuse activity.                                                                          | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/anonymous.ipset)               |
| [BotScout Global Bot List](https://blocklist.configserver.dev/3rdparty/firehol/botscout.ipset)                        | Database of known spam bots and automated systems used for account abuse and form submission attacks.                                                                       | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/botscout.ipset)                |
| [BotScout Recent Bots (1 Day)](https://blocklist.configserver.dev/3rdparty/firehol/botscout_1d.ipset)                 | Recently detected bot activity involved in automated spam and abuse attempts.                                                                                               | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/botscout_1d.ipset)             |
| [BotScout Extended Bots (30 Day)](https://blocklist.configserver.dev/3rdparty/firehol/botscout_30d.ipset)             | Longer-term bot activity aggregation capturing persistent automated abuse sources.                                                                                          | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/botscout_30d.ipset)            |
| [BotScout Weekly Bots](https://blocklist.configserver.dev/3rdparty/firehol/botscout_7d.ipset)                         | Short-term aggregation of bot activity used for spam, scraping, and automated attacks.                                                                                      | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/botscout_7d.ipset)             |
| [FireHOL Cybercrime Feed](https://blocklist.configserver.dev/3rdparty/firehol/cybercrime.ipset)                       | General cybercrime infrastructure including malware hosts, phishing sources, and attack networks.                                                                           | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/cybercrime.ipset)              |
| [FireHOL DShield Aggregation](https://blocklist.configserver.dev/3rdparty/firehol/dshield.ipset)                      | Combined intrusion detection data from global sensors tracking scanning and exploitation activity.                                                                          | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/dshield.ipset)                 |
| [DShield Recent Attacks (1 Day)](https://blocklist.configserver.dev/3rdparty/firehol/dshield_1d.ipset)                | Latest detected malicious scanning and attack activity from distributed sensors.                                                                                            | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/dshield_1d.ipset)              |
| [DShield Extended Attacks (30 Day)](https://blocklist.configserver.dev/3rdparty/firehol/dshield_30d.ipset)            | Long-term aggregation of attack sources identified across global monitoring systems.                                                                                        | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/dshield_30d.ipset)             |
| [DShield Weekly Attacks](https://blocklist.configserver.dev/3rdparty/firehol/dshield_7d.ipset)                        | Short-term attack aggregation identifying recent scanning and intrusion attempts.                                                                                           | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/dshield_7d.ipset)              |
| [GreenSnow Abuse Feed](https://blocklist.configserver.dev/3rdparty/firehol/greensnow.ipset)                           | Community-driven list of malicious IPs involved in scanning, brute-force, and exploitation activity.                                                                        | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/greensnow.ipset)               |
| [FireHOL Level 1 (Low Risk)](https://blocklist.configserver.dev/3rdparty/firehol/level1.ipset)                        | Broad low-confidence threat list including general abuse indicators and low-reputation IPs.                                                                                 | `★★⚝⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/level1.ipset)                  |
| [FireHOL Level 2 (Medium Risk)](https://blocklist.configserver.dev/3rdparty/firehol/level2.ipset)                     | Moderate confidence malicious sources including repeat scanners and abusive networks.                                                                                       | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/level2.ipset)                  |
| [FireHOL Level 3 (High Risk)](https://blocklist.configserver.dev/3rdparty/firehol/level3.ipset)                       | High-confidence malicious IPs with repeated abuse or confirmed attack behavior.                                                                                             | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/level3.ipset)                  |
| [FireHOL Level 4 (Critical Risk)](https://blocklist.configserver.dev/3rdparty/firehol/level4.ipset)                   | Highly malicious infrastructure strongly associated with botnets, malware, and active exploitation.                                                                         | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/level4.ipset)                  |
| [FireHOL Proxy Networks](https://blocklist.configserver.dev/3rdparty/firehol/proxies.ipset)                           | Known proxy services used to anonymize traffic and facilitate abuse or evasion activities.                                                                                  | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/proxies.ipset)                 |
| [FireHOL SBLAM Spam Feed](https://blocklist.configserver.dev/3rdparty/firehol/sblam.ipset)                            | Spam and botnet-related IP feed identifying sources involved in email and web spam campaigns.                                                                               | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/sblam.ipset)                   |
| [FireHOL Web Client Abuse](https://blocklist.configserver.dev/3rdparty/firehol/webclient.ipset)                       | Abusive automated web clients engaged in scraping, scanning, or exploitation attempts.                                                                                      | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/webclient.ipset)               |
| [FireHOL Web Server Abuse](https://blocklist.configserver.dev/3rdparty/firehol/webserver.ipset)                       | Compromised or malicious web servers used for hosting malware, phishing, or exploit payloads.                                                                               | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/firehol/webserver.ipset)               |
| [GreenSnow Global Blocklist](https://blocklist.configserver.dev/3rdparty/greensnow/blocklist.ipset)                   | Widely used community threat feed tracking brute-force attackers and scanning infrastructure.                                                                               | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/greensnow/blocklist.ipset)             |
| [HaGeZi Threat Intelligence](https://blocklist.configserver.dev/3rdparty/hagezi/threat_intelligence.ipset)            | Curated threat intelligence feed covering malware, phishing, trackers, and abusive infrastructure.                                                                          | `★★★★★`  | [view](https://blocklist.configserver.dev/3rdparty/hagezi/threat_intelligence.ipset)      |
| [Ipsum Threat Aggregation](https://blocklist.configserver.dev/3rdparty/ipsum/blocklist.ipset)                         | Aggregated threat intelligence from multiple sources identifying abusive and malicious IP ranges.                                                                           | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/ipsum/blocklist.ipset)                 |
| [LinuxTracker Abuse List](https://blocklist.configserver.dev/3rdparty/linuxtracker/blocklist.ipset)                   | Reputation-based list of IPs associated with abuse and suspicious activity on public tracker infrastructure.                                                                | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/linuxtracker/blocklist.ipset)          |
| [MyIP.ms ConfigServer Feed](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_configserver.ipset)         | Curated subset optimized for firewall integration targeting abusive hosting and scanning sources.                                                                           | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_configserver.ipset)  |
| [MyIP.ms Full Dataset](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_full.ipset)                      | Comprehensive reputation dataset including hosting intelligence and abusive infrastructure classifications.                                                                 | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_full.ipset)          |
| [MyIP.ms General Abuse List](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_general.ipset)             | General-purpose abuse list identifying suspicious hosting providers and malicious IP activity.                                                                              | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_general.ipset)       |
| [MyIP.ms HTAccess Blocklist](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_htaccess.ipset)            | Web server focused IP blocklist designed for .htaccess integration and HTTP filtering.                                                                                      | `★★★⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_htaccess.ipset)      |
| [MyIP.ms Web Crawlers](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_webcrawlers.ipset)               | List of known crawlers and automated agents including both benign and aggressive scraping systems.                                                                          | `★★⚝⚝⚝`  | [view](https://blocklist.configserver.dev/3rdparty/myip.ms/blocklist_webcrawlers.ipset)   |
| [Rutgers Threat Research Feed](https://blocklist.configserver.dev/3rdparty/rutgers.edu/blocklist.ipset)               | Academic threat intelligence feed containing research-identified malicious and scanning IP activity.                                                                        | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/rutgers.edu/blocklist.ipset)           |
| [SBLAM Spam Blocklist](https://blocklist.configserver.dev/3rdparty/sblam/blocklist.ipset)                             | Spam-focused IP reputation list identifying sources involved in bulk email abuse and bot activity.                                                                          | `★★★★⚝`  | [view](https://blocklist.configserver.dev/3rdparty/sblam/blocklist.ipset)                 |

<br />

To view a full listing of the blocklists we offer; visit our [API here](https://blocklist.configserver.dev/list).

<br />

---

<br />

## References for More Help

If you need additional help apart from this README; use the following pages as references:

<br />

---

<br />

## Contributors ✨

We are always looking for contributors. If you feel that you can provide something useful to Gistr, then we'd love to review your suggestion. Before submitting your contribution, please review the following resources:

- [Pull Request Procedure](.github/PULL_REQUEST_TEMPLATE.md)
- [Contributor Policy](CONTRIBUTING.md)

<br />

Want to help but can't write code?
- Review [active questions by our community](https://github.com/ConfigServerApps/service-blocklists/labels/help%20wanted) and answer the ones you know.

<br />

![Alt](https://repobeats.axiom.co/api/embed/a968656a3592fa904ffbcc3abd666aa2d40b8648.svg "Repobeats analytics image")

<br />

The following people have helped get this project going:

<br />

<div align="center">

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![Contributors][contribs-all-img]](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top"><a href="https://gitlab.com/Aetherinox"><img src="https://avatars.githubusercontent.com/u/118329232?v=4?s=40" width="80px;" alt="Aetherinox"/><br /><sub><b>Aetherinox</b></sub></a><br /><a href="https://github.com/ConfigServerApps/service-blocklists/commits?author=Aetherinox" title="Code">💻</a> <a href="#projectManagement-Aetherinox" title="Project Management">📆</a> <a href="#fundingFinding-Aetherinox" title="Funding Finding">🔍</a></td>
    </tr>
  </tbody>
</table>
</div>
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

<br />
<br />

<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- BADGE > GENERAL -->
  [general-npmjs-uri]: https://npmjs.com
  [general-nodejs-uri]: https://nodejs.org
  [general-npmtrends-uri]: http://npmtrends.com/csf-firewall

<!-- BADGE > VERSION > GITHUB -->
  [github-version-img]: https://img.shields.io/github/v/tag/ConfigServerApps/service-blocklists?logo=GitHub&label=Version&color=ba5225
  [github-version-uri]: https://github.com/ConfigServerApps/service-blocklists/releases

<!-- BADGE > VERSION > NPMJS -->
  [npm-version-img]: https://img.shields.io/npm/v/csf-firewall?logo=npm&label=Version&color=ba5225
  [npm-version-uri]: https://npmjs.com/package/csf-firewall

<!-- BADGE > VERSION > PYPI -->
  [pypi-version-img]: https://img.shields.io/pypi/v/csf-firewall-plugin
  [pypi-version-uri]: https://pypi.org/project/csf-firewall-plugin/

<!-- BADGE > LICENSE > MIT -->
  [license-mit-img]: https://img.shields.io/badge/MIT-FFF?logo=creativecommons&logoColor=FFFFFF&label=License&color=9d29a0
  [license-mit-uri]: https://github.com/ConfigServerApps/service-blocklists/blob/main/LICENSE

<!-- BADGE > GITHUB > DOWNLOAD COUNT -->
  [github-downloads-img]: https://img.shields.io/github/downloads/ConfigServerApps/service-blocklists/total?logo=github&logoColor=FFFFFF&label=Downloads&color=376892
  [github-downloads-uri]: https://github.com/ConfigServerApps/service-blocklists/releases

<!-- BADGE > NPMJS > DOWNLOAD COUNT -->
  [npmjs-downloads-img]: https://img.shields.io/npm/dw/%40aetherinox%2Fcsf-firewall?logo=npm&&label=Downloads&color=376892
  [npmjs-downloads-uri]: https://npmjs.com/package/csf-firewall

<!-- BADGE > GITHUB > DOWNLOAD SIZE -->
  [github-size-img]: https://img.shields.io/github/repo-size/ConfigServerApps/service-blocklists?logo=github&label=Size&color=59702a
  [github-size-uri]: https://github.com/ConfigServerApps/service-blocklists/releases

<!-- BADGE > NPMJS > DOWNLOAD SIZE -->
  [npmjs-size-img]: https://img.shields.io/npm/unpacked-size/csf-firewall/latest?logo=npm&label=Size&color=59702a
  [npmjs-size-uri]: https://npmjs.com/package/csf-firewall

<!-- BADGE > CODECOV > COVERAGE -->
  [codecov-coverage-img]: https://img.shields.io/codecov/c/github/ConfigServerApps/service-blocklists?token=MPAVASGIOG&logo=codecov&logoColor=FFFFFF&label=Coverage&color=354b9e
  [codecov-coverage-uri]: https://codecov.io/github/ConfigServerApps/service-blocklists

<!-- BADGE > ALL CONTRIBUTORS -->
  [contribs-all-img]: https://img.shields.io/github/all-contributors/ConfigServerApps/service-blocklists?logo=contributorcovenant&color=de1f6f&label=contributors
  [contribs-all-uri]: https://github.com/all-contributors/all-contributors

<!-- BADGE > GITHUB > BUILD > NPM -->
  [github-build-img]: https://img.shields.io/github/actions/workflow/status/ConfigServerApps/service-blocklists/npm-release.yml?logo=github&logoColor=FFFFFF&label=Build&color=%23278b30
  [github-build-uri]: https://github.com/ConfigServerApps/service-blocklists/actions/workflows/npm-release.yml

<!-- BADGE > GITHUB > BUILD > Pypi -->
  [github-build-pypi-img]: https://img.shields.io/github/actions/workflow/status/ConfigServerApps/service-blocklists/release-pypi.yml?logo=github&logoColor=FFFFFF&label=Build&color=%23278b30
  [github-build-pypi-uri]: https://github.com/ConfigServerApps/service-blocklists/actions/workflows/pypi-release.yml

<!-- BADGE > GITHUB > TESTS -->
  [github-tests-img]: https://img.shields.io/github/actions/workflow/status/ConfigServerApps/service-blocklists/npm-tests.yml?logo=github&label=Tests&color=2c6488
  [github-tests-uri]: https://github.com/ConfigServerApps/service-blocklists/actions/workflows/npm-tests.yml

<!-- BADGE > GITHUB > COMMIT -->
  [github-commit-img]: https://img.shields.io/github/last-commit/ConfigServerApps/service-blocklists?logo=conventionalcommits&logoColor=FFFFFF&label=Last%20Commit&color=313131
  [github-commit-uri]: https://github.com/ConfigServerApps/service-blocklists/commits/main/

<!-- prettier-ignore-end -->
<!-- markdownlint-restore -->

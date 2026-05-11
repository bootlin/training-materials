#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Maintenance, regulation and compliance

=== Rationale

- "Cybersecurity" has been a rapidly growing concern

- The stakes are high:

  - Reputation

  - Downtime

  - Money (blackmail, ransomware)

- You can actually buy cybersecurity insurance

- Some vulnerabilities have wide-reaching consequences for everyone

- Predictably, this has led to produce standards and legislation

=== Examples

- standards

  - ISO 27001

  - NIST standards, such as

    - the Federal Information Processing Standard (FIPS)

    - the Advanced Encryption Standard (AES)

  - Common Criteria

- laws

  - Federal Information Security Modernization Act (FISMA)

  - The Cyber Resilience Act
    (#link("https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120")[CRA])

== Vulnerability frameworks
<vulnerability-frameworks>

=== Vulnerability taxonomy

- A Vulnerability is a rather high-level concept

- Very different phenomena can be deemed a vulnerability:

  - Having a deprecated feature still present in a UI

  - Using HTTP

  - Use-after-frees

  - etc...

- The MITRE corporation has a categorization of vulnerabilities by
  category: the
  #link("https://cwe.mitre.org/")[Common Weakness Enumeration (CWE)]

- CWE uses different categories to organize vulnerabilities

=== Vulnerability databases

- Idea: central repository listing published vulnerabilities

- The main problem here is maintenance

- The reference was the U.S National Vulnerability Database (NVD)

  - Funding issues have fragilized NVD as a reliable source

- China has 2 databases: CNVD and CNNVD

  - Both require accounts and can be difficult to navigate

- The EU has started the
  #link("https://euvd.enisa.europa.eu/search")[EUVD] in 2025

  - Uses UUIDs for vendors and products

  - Version ranges are not super trivial to parse

=== The CVE program

- CVE stands for "Common Vulnerabilities and Exposures"

- Has been operated by MITRE with US government funding

- This funding has had ups and downs in 2025, which has led to data
  quality issues

- #link(
    "https://www.cve.org/programorganization/cnas",
  )[CVE Numbering Authorities (CNAs)]
  can reserve and assign CVE numbers within their scope

- The Linux kernel team became a CNA in early 2024

- This is the program that serves as a base for the NVD

- Usually contains mostly rudimentary information at first

- Database is cached into a
  #link("https://github.com/CVEProject/cvelistV5")[github repo]

=== Common Vulnerability Scoring System (CVSS)

- Open Framework published by FIRST
  (#link("https://www.first.org/cvss/specification-document")[specification])

- Current version is 4 since November 2023

- Usually, CVE records will use 1 or 2 versions of CVSS, depending on
  publication date

- CVSS results in:

  - A "vector" representing the values of a discrete set of metrics

  - A score between 0 and 10, which is a numerical conversion of the
    vector

- The score is the result of a complex-ish
  #link("https://github.com/FIRSTdotorg/cvss-v4-calculator")[computation]
  (#link("https://redhatproductsecurity.github.io/cvss-v4-calculator/")[online calculator])

=== Exploitation Predictability Scoring System (EPSS)

- Relatively recent (2021) effort

- Backed by FIRST

- Gives an estimated probability of the vulnerability being exploited
  within the next 30 days

- Uses machine learning to correlate exploit activity to vulnerabilities

- Relies on closed-source data from industry partners re: exploitation

- One big question here is how big the blind spot due to the
  incompleteness of the exploitation data is

=== Common Platform Enumerations (CPEs)

- CPEs are unambiguous identifiers for a specific product

- Can be very specific, or use wildcards (such as "\*") to identify a
  range of products

- CPE is a MITRE trademark

- An authoritative
  #link("https://nvd.nist.gov/products/cpe")[dictionary] of CPEs is
  maintained by the NIST

- The #link("https://csrc.nist.gov/pubs/ir/7695/final")[specification]
  is also published by the NIST

- Structure of a CPE:
  #text(size: 18pt)[
    `cpe:<version>:<part>:<vendor>:<product>:<version>:<update>:<edition>:<language> \\
     :<sw_edition>:<target_sw>:<target_hw>:<other>
  `]

- Example for
  #link("https://github.com/CVEProject/cvelistV5/blob/main/cves/2026/22xxx/CVE-2026-22174.json")[CVE-2026-22174]:

  ```yaml cpe:2.3:a:openclaw:openclaw:*:*:*:*:*:node.js:*:```

=== Summary

- _CWE_\s (Common Weakness Enumerations) classify vulneraibilities
  into types.

- _CVE_\s (Common Vulnerabilities and Exposures) inventory
  individual vulnerabilities
  #link("https://nvd.nist.gov/vuln/detail/CVE-2012-5109")[CVE-2012-5109]
  and
  #link("https://nvd.nist.gov/vuln/detail/CVE-2025-29834")[CVE-2025-29834]
  are both examples of
  #link("https://cwe.mitre.org/data/definitions/125.html")[CWE-125]: \
  Out-of-bounds Read

- _CVSS_ scores give a "grade" from 0 to 10 (critical) to the
  vulnerability

  - broken down into a vector along metrics (privilege,
    physical/local/network, user interaction...)

- _EPSS_ is a score trying to predict the likelyhood of the
  vulnerability being exploited

- _CPE_\s (Common Plaftorm Enumerations) are identifiers for the
  target (software or hardware)

  - They can be specific e.g. to a version, or a patch level

== Regulation
<regulation>

=== The Cyber Resiliance Act #link("https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120")[CRA]

- European Law adopted on October 10 2024

  - Most dispositions start applying on December 11 2027

  - Manufacturer's reporting obligations to
    #link("https://www.enisa.europa.eu/")[ENISA] start on September 11
    2026

- Applies to products placed on the European market

  - "Products" in this case include software

- Enforces obligations from different actors regarding cybersecurity

- Introduces a minimum amount of time these obligations must be carried
  out: the support period

=== #link("https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120")[CRA]: support period

- It is defined in Article 13, paragraph 8

- Determined by the manufacturer, taking into account:

  - EU law (other than CRA) if existing

  - ADCO (ADministrative COoperation group) guidance

  - comparable products' support period

  - the "availability of the operating environment"

  - the support period of critical components

- Minimum is 5 years unless the product cannot reasonably be expected to
  last that long

=== #link("https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120")[CRA]: useful resources

- The
  #link(
    "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120",
  )[law]

- The european comission has an implementation
  #link(
    "https://digital-strategy.ec.europa.eu/en/library/cyber-resilience-act-implementation-frequently-asked-questions",
  )[FAQ]

- Draft candidates for future ETSI
  #link("https://docbox.etsi.org/CYBER/EUSR/Open")[standards]

== Software Bill of Materials
<software-bill-of-materials>

=== SBoM

- CRA definition:

  `a formal record containing details and supply chain relationships of components included in the software elements of a product with digital elements; a commonly used and machine-readable format covering at the very least the top-level dependencies of the products
  `

- #link(
    "https://www.cisa.gov/resources-tools/resources/shared-vision-software-bill-materials-sbom-cybersecurity",
  )[High-level explanation]

- SBoMs are supposed to give end-users a good overview of their
  dependencies

- Without them, answering "are we using component X" can be hard

=== SBom standards

- No law imposes a specific format for SBoMs

- Two main standards are competing:

  - #link("https://cyclonedx.org/")[CycloneDX]

  - #link("https://spdx.dev/")[SPDX]

=== #link("https://cyclonedx.org/")[CycloneDX]

- #link(
    "https://ecma-international.org/publications-and-standards/standards/ecma-424/",
  )[Standard]
  published by ECMA (ECMA-424 as of December 2025)

- Supports the following serialization formats:

  - JSON (JavaScript Object Notation)

  - XML (eXtensible Markup Language)

  - Protocol buffers

- Tends to be supported by commercial tools

  - SBoM Studio (Cybeats)

  - SBoM Manager (Keysight)

=== #link("https://spdx.dev/")[SPDX]

- Software Package Data eXchange

- Open Source project hosted by the Linux Foundation

- #link("https://www.iso.org/standard/81870.html")[Standard] published
  by ISO

- Two versions coexist:

  - 2.3 is widely supported, and the current ISO standard

  - 3.0 tooling is trailing a bit, and the next ISO standard (draft)

- Tends to be supported by open-source tools

=== SPDX3: Example

#text(size: 10pt)[
  ```json
  {
    "@context": "https://spdx.org/rdf/3.0.1/spdx-context.jsonld",
    "@graph": [
      {
        "type": "CreationInfo",
        "@id": "_:CreationInfo1",
        "created": "2011-04-05T23:00:00Z",
        "createdBy": ["http://spdx.org/spdxdocs/bitbake-addba517-4804-5ae3-87c2-0c3a1a5812ba/bitbake/agent/OpenEmbedded"],
        "createdUsing": ["http://spdx.org/spdxdocs/bitbake-addba517-4804-5ae3-87c2-0c3a1a5812ba/bitbake/tool/oe-spdx-creator_1_0"],
        "specVersion": "3.0.1"
      },
      ...
      {
        "type": "Relationship",
        "spdxId": "http://spdx.org/spdxdocs/kiss-image-289390b0-d487-53ac-ab83-c6af87b87d1f/9f6c<...>1961/relationship/4a02<...>82ee",
        "creationInfo": "_:CreationInfo1",
        "extension": [
          {
            "type": "https://rdf.openembedded.org/spdx/3.0/id-alias",
            "https://rdf.openembedded.org/spdx/3.0/alias":
              "http://spdxdocs.org/openembedded-alias/by-doc-hash/cdfb<...>c0ee/kiss-image/UNIHASH/relationship/4a02dce12485470d12bf7e20117282ee"
          }
        ],
        "from": "http://spdx.org/spdxdocs/kiss-image-289390b0-d487-53ac-ab83-c6af87b87d1f/9f6c<...>1961/rootfs/kiss-image",
        "relationshipType": "contains",
        "to": [
          "http://spdx.org/spdxdocs/kiss-image-289390b0-d487-53ac-ab83-c6af87b87d1f/9f6c<...>1961/rootfs-file/etc_default_dropbear",
          "http://spdx.org/spdxdocs/kiss-image-289390b0-d487-53ac-ab83-c6af87b87d1f/9f6c<...>1961/rootfs-file/etc_group"
          ...
        ]
  }
  ```]

=== #link(
  "https://www.cisa.gov/resources-tools/resources/minimum-requirements-vulnerability-exploitability-exchange-vex",
)[VEX]

- Vulnerability Exploitability eXchange

- Not actually a standard: CISA only defines a set of minimum
  requirements

- There are a few implementation options:

  - CycloneDX integrates VEX within the _vulnerabilities_ property

  - The Common Security Advisory Framework
    (#link("https://www.csaf.io/")[CSAF]) defines a VEX profile

  - #link("https://openvex.dev/")[OpenVEX] is a community-driven
    standard of VEX that meets the CSAF minimum requirements

- The SBoM is an inventory of the software which can be used to lookup
  vulnerabilities

- VEX expresses e.g. the applicability of those vulnerabilities

=== SPDX3: Example

#text(size: 14pt)[
  ```json
      {
        "name": "busybox",
        "layer": "meta",
        "version": "1.36.1",
        "products": [
          {
            "product": "busybox",
            "cvesInRecord": "No"
          }
        ],
        "cpes": [ "cpe:2.3:*:*:busybox:1.36.1:*:*:*:*:*:*:*" ],
        "issue": [
          {
            "id": "CVE-2021-42380",
            "status": "Patched",
            "link": "https://nvd.nist.gov/vuln/detail/CVE-2021-42380",
            "detail": "backported-patch"
          },
          {
            "id": "CVE-2022-28391",
            "status": "Patched",
            "link": "https://nvd.nist.gov/vuln/detail/CVE-2022-28391",
            "detail": "backported-patch"
          },
        ]
      }
  ```]

=== Generating your SBoM

- #link("https://buildroot.org/")[Buildroot]:

  - generates a JSON blurb listing packages with `make show-info` and
    `make pkg-stats`

  - can convert that output to CycloneDX using
    #link(
      "https://github.com/buildroot/buildroot/blob/master/utils/generate-cyclonedx",
    )[utils/generate-cyclonedx]

- #link("https://www.yoctoproject.org/")[Yocto]

  - has a
    #link(
      "https://github.com/openembedded/openembedded-core/blob/master/meta/classes/create-spdx.bbclass",
    )[create-spdx]
    class, which supports both SPDX 2.3 and SPDX 3.0

  - process is documented
    #link("https://docs.yoctoproject.org/dev/dev-manual/sbom.html")[here]

  - also has a
    #link(
      "https://github.com/openembedded/openembedded-core/blob/master/meta/classes/vex.bbclass",
    )[vex]
    class, which was used to generate the example VEX

  - Yocto can annotate a CVE's status, as e.g. in their
    #link(
      "https://github.com/openembedded/openembedded-core/blob/master/meta/recipes-kernel/linux/cve-exclusion.inc",
    )[exclusion lists]

=== Using the SBoM

- SBoMs are a catalogue of the software on your device, including its
  version

- They can be used to look up vulnerabilities in databases (NVD,
  CVElistV5, EUVD...)

- They can also include _annotations_ in the form of VEX
  information

  - For instance, yocto includes annotations that are part of the layer
    in their SBoMs

- They can be used periodically to scan _new_ vulnerabilities,
  without rebuilding

=== VulnScout

- Open Source tool from Savoir-faire Linux

- Graphical interface

- Uses a docker container for the HTTP server

- Supports SPDX2.2, SPDX 3 and Cyclone DX

=== VulnScout

#image("vulnscout.png", height: 90%)

=== sbom-cve-check

- Open Source tool from Bootlin

- #link("https://github.com/bootlin/sbom-cve-check")[code] -
  #link("https://sbom-cve-check.readthedocs.io/en/latest/")[documentation]

- Written in python, with as few dependencies as possible

- SBoM enrichment based on CVE databases: NVD, CVElistV5

- Supports SPDX 2.2 (Yocto's format) and SPDX 3

- Can take CVE annotations in format:

  - simple-annotations (YAML)

  - Yocto VEX manifest

  - OpenVEX

== Upgrading strategy
<upgrading-strategy>

=== Upgrades

- Updates can be necessary for multiple reasons:

  - Patching a security vulnerability

  - Rotating cryptographic material (e.g. later stage secure boot keys)

  - Legal obligation (e.g. CRA)

  - Adding functionality

- Some upgrades are simple, e.g. deploying a patch

- Version upgrades can be hard, especially when skipping over versions

=== Picking a version

- Embedded systems rely on a plethora of Open Source projects

- A lot of work is done *upstream*

- When a vulnerability is found or reported, or an important bug is
  fixed, only *supported versions* will get the fix

- The further one's version strays from a supported version, the harder
  *tracking* and *porting* fixes becomes

- In terms of security, being on the newest stable version is usually
  best

- The issue is compatibility

=== Long-Term Support

- Long-Term Support (LTS) versions stay supported for longer

  - Linux kernel LTS versions are supported for 2 years minimum

  - Yocto LTS versions receive 4 years of support

  - Buildroot LTSs are supported for 3 *years* instead of 3
    *months*

- This is advertised plainly:

  - the Linux kernel has a
    #link("https://www.kernel.org/category/releases.html")[list of LTS versions]

  - so does the
    #link("https://www.yoctoproject.org/development/releases/")[Yocto project]

  - the same for #link("https://buildroot.org/lts.html")[buildroot]

- The #link("https://cip-project.org/")[Civil Infrastructure Platform]
  aims to extend LTS windows to over 5 years

  - consortium of large industry members

  - under the Linux Foundation

  - some features are introduced, not just fixes

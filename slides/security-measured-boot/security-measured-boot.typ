#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Measured boot

== Concept
<concept>

===  Measured boot

- Another way of establishing *trust*

- Idea: measure caracteristics of the system and record the measurement

- One major target for measurement is the software being run

- Other targets include:

  - configuration (e.g. U-Boot environment)

  - boot parameters (e.g. kernel command line)

- Also called *trusted* boot `!=` secure/verified boot

===  Differences from Secure Boot

- The software is not *authenticated*, only *measured*

- To be useful, the measurement needs to be used to make some decision

- This is a different step called *attestation* or
  *appraisal*

- It can only consist of recording the measurement discrepancy, or more
  complex actions

===  Measurements

- A measurement is a hash of the data we are trying to measure

- We need to use a cryptographically secure hash function

- In a later step, we'll want to compare this hash to a known-good value

- We need to store these hashes

===  Measured boot support

- A lot of the software components we've already covered support
  Measured boot:

  - TF-A

  - U-Boot

- systemd supports measured boot using
  #link("https://www.freedesktop.org/software/systemd/man/latest/systemd-measure.html")[systemd-measure]

  - this feature is experimental

  - currently only supports UKI, which are mostly used in UEFI boots

== Trusted Platform Module (TPM)
<trusted-platform-module-tpm>

===  Trusted Platform Module

- Dedicated and isolated crypto component

- Following the
  #link("https://trustedcomputinggroup.org/")[Trusted Computing Group]
  (TCG)'s specification:

  - #link("https://trustedcomputinggroup.org/resource/tpm-main-specification/")[TPM 1.2],
    originally published in 2003

  - TPM 2.0 Library, also known as ISO/IEC 11889

- In 1.2, the TPM was explicitly specified as a hardware component
  including a crypto co-processor among others.

- The current 2.0 spec explicitly drops this requirement \
  `Another reasonable implementation of a TPM is to have the code run on
  the host processor while the processor is in a special execution mode`

===  TPM 2.0

- Current version of the specification

- This is e.g. the one that is a Windows 11 requirement

- Specifies the TPM as a _library_

- The TCG's
  #link("https://trustedcomputinggroup.org/wp-content/uploads/2019_TCG_TPM2_BriefOverview_DR02web.pdf")[Brief overview]
  recognizes 5 types of TPM:

  - Discrete TPMs, or dTPM: dedicated hardened chip \
    example: the
    #link("<https://www.st.com/en/secure-mcus/st33ktpm2x.html")[ST33KTPM2X]

  - Integrated TPMs: co-processor. Examples:

    - Microsoft's
      #link("https://learn.microsoft.com/en-us/windows/security/hardware-security/pluton/microsoft-pluton-security-processor")[Pluton]

    - The AMD
      #link("https://dayzerosec.com/blog/2023/04/17/reversing-the-amd-secure-processor-psp.html")[Secure Processor]
      (ASP, or PSP)

  - Firmware TPMs, or fTPMs: hardware-isolated software. Examples:

    - the #link("https://github.com/OP-TEE/optee_ftpm")[OP-TEE fTPM]

  - Software TPMs: only useful for testing \
    example: this
    #link("https://github.com/microsoft/ms-tpm-20-ref")[reference implementation]
    from Microsoft.

  - Virtual TPMs, or vTPMs: basically an fTPM running in a hypervisor \
    Google
    #link("https://cloud.google.com/blog/products/identity-security/virtual-trusted-platform-module-for-shielded-vms-security-in-plaintext?hl=en")[implemented one]
    for GCP

===  Using the TPM

- Key storage and generation

- Platform Configuration Registers (PCRs)

  - "Shielded Locations", meaning hardware protected by the TPM

  - Meant to contain a log of measurements

  - Some persist across reboot, most should be reset to initial value

  - Initial value must be all 0s or all 1s, except for PCR[0], which
    can be used as a locality indicator

  - Cannot be set, only *reset* or *extended*

    - This means hashing the current value of the PCR appended with the
      measurement

    - The order of measurement therefore impacts the final PCR value

===  Additional references

- The Open Security Training 2 "Trusted Computing" track:
  #link("https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+TC1101_IntroTPM+2024_v2/about")[TC1101],
  #link("https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+TC1102_IntermediateTPM+2024_v1/about")[TC1102],
  #link("https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+TC2202_tpm2-pytss+2025_v1/about")[TC2202]

- The Open Access
  #link("https://link.springer.com/book/10.1007/978-1-4302-6584-9")[Practical Guide to TPM 2.0]

== IMA/EVM
<imaevm>

===  Integrity Measurement Architecture (IMA)

- #link("https://ima-doc.readthedocs.io/en/latest/index.html")[IMA] is a
  Linux kernel subsystem, found under `security/integrity/ima`

- Uses extended attributes
  (#kdochtml("filesystems/ext4/attributes.html")) to store
  measurement of files at runtime.

- Enabled via #kconfig("CONFIG_IMA")

- Continues the measurement process after the kernel takes over

- Focuses on the integrity of file *contents*

===  Integrity Measurement Architecture Appraisal

- IMA appraisal validates the integrity of file content

- File content is verified either with:

  - A hash: file content is protected against offline modifications

  - A signature: file content is protected against both offline and
    online modifications

- Only the file content is validated: nothing prevent from renaming a
  file or replacing it with another valid file

- IMA appraisal behaviour is controlled by the `ima_appraise` kernel
  command line parameter:

  - `enforce` appraisal is fully enabled: access to file with invalid or
    missing hashes of signatures is denied

  - `log` access to file with invalid or missing hashes or signature is
    allowed, but logged

  - `fix` hashes of files covered by the policy are updated, when a file
    is accessed

  - `off`: appraisal is completely disabled: hashes or signature are
    neither generated nor validates

===  Integrity Measurement Architecture Policies

- Policies defines what is measured

- Controlled by the `ima_policy` kernel command line parameter

- Several policies can be combined

- IMA comes with predefined policies:
  #[ #set list(spacing: 0.3em)
  - Controls what is measured

  - `tcb`: measures all executed programs, files mmap'd for execution,
    and all files read with uid or effective uid set to 0

  - `appraise_tcb` appraises the integrity of all files owned by root

  - `secure_boot` appraises the integrity of files based on file
    signatures

  - `fail_securely` always force file signature verification

  - `critical_data` measures kernel integrity critical data
  ]
- Custom policies can be defined

  - Only well-known stable files should be measured
    #v(-0.3em)
    - Binaries, libraries, configuration…

  - Files with frequent modifications should not be measured
    #v(-0.3em)
    - Logs, databases…

===  Extended Verification Module (EVM)

- #link("https://ima-doc.readthedocs.io/en/latest/ima-concepts.html#extended-verification-module-evm")[EVM]
  is also a Linux kernel subsystem, found under `security/integrity/evm`

- Uses extended attributes
  (#kdochtml("filesystems/ext4/attributes.html")) to store
  measurement of files at runtime.

- Enabled via #kconfig("CONFIG_EVM")

- Continues the measurement process after the kernel takes over

- Focuses on the integrity of file *metadata*

===  Extended Verification Module (EVM)

- Similarly to IMA, EVM is split into:

  - EVM HMAC: allows to protect against offline modifications

  - EVM Signature: also protects against runtime modifications

- EVM can be enabled with the `securityfs` pseudo-filesystem: \
  `/sys/kernel/security/evm`:

  - Value is a bit mask of enabled configuration, bits can only
    transition from 0 to 1

  - bit 0: Enable HMAC validation and creation

  - bit 1: Enable digital signature validation

  - bit 31: Disable further runtime modification of EVM policy

- As for IMA, nothing prevent from renaming the file: filename is not
  part of the metadata

===  IMA/EVM vs dm-verity

- Both aim to enforce userland integrity

- IMA/EVM enables:

  - remote attestation

  - auditing

- This comes at the cost of a more complicated setup

- IMA policies must be crafted very carefully

- Neither is very useful without a full secure boot chain

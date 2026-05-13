#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Handling confidential information

=== Problem statement

- Most systems handle some type of confidential information

  - Customer/User data

  - Intellectual Property

  - Cryptographic material (private keys)

- The usual way to protect it is *encryption*

- Raises the issue of storing the *key*

- This is a hard problem on embedded systems

  - adversaries might have physical access to the system

  - unattended boot is incompatible with keys derived from user input

== Hardware Security Modules (HSMs)
<hardware-security-modules-hsms>

=== HSMs

- Dedicated Hardware for storing cryptographic secrets

- Implements cryptographic operations:

  - key generation

  - encryption

  - signing

- Prevent the key from leaving in cleartext form

- Some can be exported in *wrapped* (encrypted) form

- Separate usage of various keys based on PINs

=== HSMs: threat model

- HSMs split

  - *usage* of cryptographic material from

  - *knowledge* of the cryptographic material

- In case of compromise, this means recovery can happen without rotation

- HSMs do not necessarily prevent an adversary from *using* the
  key

=== HSMs: usage

- HSMs are usually used to store sensitive keys

  - Secure boot root keys

  - PKI root CA private keys

  - DNSSEC signature keys

  - Blockchain account private keys (cryptographic wallets)

- Some HSMs have an on-device interface (screen + buttons)

- All HSMs implement a command interface, and a PKCS\#11 API

=== "Software HSMs"

- Strange concept at first glance

- This is the difference between "hot" and "cold" crypto wallets

- Much less secure than an actual hardware device

- Also less expensive, and potentially easier to use

- Examples:

  - #link("https://www.softhsm.org/")[SoftHSM]

  - OP-TEE has a
    #link(
      "https://github.com/OP-TEE/optee_os/tree/master/ta/pkcs11",
    )[PKCS\#11 TA]

== PKCS\#11
<pkcs11>

=== PKCS

- Public Key Cryptography Standards

- Set of standards published by RSA Security

- Some are more relevant than others:

  - PKCS\#1, or
    #link("RFC 8017")[https://datatracker.ietf.org/doc/html/rfc8017] is
    the RSA specification

  - PKCS\#3 describes the Diffie-Hellman key agreement protocol

  - PKCS\#7 or
    #link("RFC 2315")[https://datatracker.ietf.org/doc/html/rfc2315]
    describes the Cryptographic Message Syntax (CMS)

  - PKCS\#10 is a common format for Certificate Signing Requests (CSRs)

  - PKCS\#11, or "Cryptoki" is the Cryptographic Token Interface

=== PKCS\#11

- CRYPtographic TOKen Interface

- v1.0 published by RSA Security in 1995

- Libraries implementing it are often called cryptoki

- Since 2013, overseen by an
  #link(
    "https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=pkcs11",
  )[OASIS technical committee]

- The specification includes C header files

- It is then up to token manufacturers to implement the API

  - Nitrokeys'
    #link("https://github.com/Nitrokey/nethsm-pkcs11")[nethsm-pkcs11]

  - Yubico's
    #link(
      "https://developers.yubico.com/yubihsm-shell/yubihsm-pkcs11.html",
    )[PKCS11 module for YubiHSM]

  - Thales' libCryptoki2, part of the Luna client

=== PKCS\#11 clients

- PKCS\#11 is very specific (even implements a header)

- Token-specific implementations are usually shared objects

- So we can have a generic client compatible with all modules:

  - OpenSSL, via a
    #link("https://github.com/openssl-projects/pkcs11-provider")[provider]

  - GnuTLS'
    #link(
      "https://www.gnutls.org/manual/html_node/p11tool-Invocation.html",
    )[p11tool]

== Cryptographic keys in the kernel
<cryptographic-keys-in-the-kernel>

=== The Kernel Key Retention Service

- Also called "Kernel Key Ring Service", or "Kernel keyring"

- Documented in #kdochtml("security/keys/core")

- Can essentially act as a software HSM

- The protection here is against adversaries that have gotten
  unprivileged code execution

=== Trusted & Encrypted Keys

- Specific key types in the Kernel keyring

- Stored in plaintext in kernel memory, only exportable wrapped

- The kernel sort of acts as an HSM for userland

- *Trusted key* encryption is harware-backed

- *Encrypted key* encryption is backed by a kernel keyring key

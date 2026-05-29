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
    #link("https://datatracker.ietf.org/doc/html/rfc8017")[RFC 8017] is
    the RSA specification

  - PKCS\#3 describes the Diffie-Hellman key agreement protocol

  - PKCS\#7 or
    #link("https://datatracker.ietf.org/doc/html/rfc2315")[RFC 2315]
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

- The specification includes
  #link(
    "https://github.com/oasis-tcs/pkcs11/tree/pkcs11-3.00/published/3-00",
  )[C header files]

- It is then up to token manufacturers to implement the API

  - Nitrokeys'
    #link("https://github.com/Nitrokey/nethsm-pkcs11")[nethsm-pkcs11]

  - Yubico's
    #link(
      "https://developers.yubico.com/yubihsm-shell/yubihsm-pkcs11.html",
    )[PKCS11 module for YubiHSM]

  - Thales' libCryptoki2, part of the Luna client

=== PKCS\#11 functions

Below are some examples of functions declared in the `pkcs11f.h` header:
#[ #show raw.where(lang: "c", block: true): set text(size: 13pt)
  ```c
  /* C_Initialize initializes the Cryptoki library. */
  CK_PKCS11_FUNCTION_INFO(C_Initialize)

  /* C_Finalize indicates that an application is done with the
   * Cryptoki library.
   */
  CK_PKCS11_FUNCTION_INFO(C_Finalize)

  /* C_GetMechanismList obtains a list of mechanism types
   * supported by a token.
   */
  CK_PKCS11_FUNCTION_INFO(C_GetMechanismList)
  ```
]

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

=== The OP-TEE PKCS\#11 TA

- Implements the PKCS\#11 interface over the kernel's interface to the TEE

- The "vendor" module is optee_client's
  #link(
    "https://github.com/OP-TEE/optee_client/tree/master/libckteec",
  )[`libckteec.so`]

- Requires the TA to be loaded in OP-TEE

  - this a perfect job for the
    #link("https://github.com/OP-TEE/optee_client/blob/master/libckteec/src/pkcs11_api.c#L95")[`C_Initialize`] function.
  - Ultimately, `ckteec_invoke_init` is called:

  #[ #show raw.where(lang: "c", block: true): set text(size: 13pt)
    ```c
    CK_RV ckteec_invoke_init(void)
    {
             TEEC_UUID uuid = PKCS11_TA_UUID;
    ...
             res = TEEC_InitializeContext(NULL, &ta_ctx.context);
             if (res != TEEC_SUCCESS) {
                     EMSG("TEEC init context failed\n");
                     rv = CKR_DEVICE_ERROR;
                     goto out;
             }

             res = TEEC_OpenSession(&ta_ctx.context, &ta_ctx.session, &uuid,
                                    login_method, login_data, NULL, &origin);
    ...
    }
    ```]

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

- *Trusted key* encryption is hardware-backed

- *Encrypted key* encryption is backed by a kernel keyring key

#setuplabframe([Exploring secure key management], [
  Time to handle confidential information!

  - Provisioning keys into the i.MX93 ELE

  - Using OP-TEE as software HSM

  - Optionally, filesystem encryption using the ELE key

  - Optionally, signing U-Boot FITs with HSM integration over PKCS\#11

])

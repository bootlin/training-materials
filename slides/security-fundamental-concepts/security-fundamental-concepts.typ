#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Fundamental concepts

== Threat modeling
<threat-modeling>

=== What is threat modeling?
<what-is-threat-modeling>

- Threat modeling is the process of listing and organizing potential
  threats and appropriate responses

- Helps to:

  - Identify potential threats

  - Prioritize them based on the risk

  - Identify possible countermeasures

- Provides an analysis of what affects the security and which measures
  need to be implemented

- A large number of framworks and methodologies exist.

=== Security properties: CIA triad
<security-properties-cia-triad>

- *Confidentiality*: Can an unauthorized entity gain access to
  information?

- *Integrity*: Can there be unauthorized modification of
  information?

- *Availability*: Can authorized access to information be
  impended?

=== Confidentiality
<confidentiality>

- The main property one wants out of a secure information system

- Typical adversary: *passive* MITM

- Protecting it is *encryption*'s main role

- Can make it harder to ensure *Availability*

=== Integrity
<integrity>

- Aims to ensure that information is not modified

- Typical adversary is an *active* MITM

- The most basic form of protection are checksums

=== Availability
<availability>

- Aims to ensure that information is accessible

- Typical adversaries are DoS attacks

- Defense usually involves:

  - early detection of threats

  - redundancy and failover

- Maintaining availability can lead to compromising on confidentiality,
  this is what some scams rely on.

=== In cybersecurity: the five pillars
<in-cybersecurity-the-five-pillars>

- *Confidentiality*: Can an unauthorized entity gain access to
  information?

- *Integrity*: Can there be unauthorized modification of
  information?

- *Availability*: Can authorized access to information be
  impended?

- *Authenticity*: Can an unauthorized entity insert
  undistinguishable information?

- *Non-repudiation*: Can an authorized entity deny some
  information's authenticity?

The *Parkerian hexad* introduces

- *Utility*: Is the information useful?

and trades *Non-repudiation* for

- *Control*: Can authorized users access information?

=== Authenticity
<authenticity>

- Aims to ensure that information (e.g.) a message came from a source

- This is what digital signatures aim to protect

- This is not the same as integrity:

  - No protection against *replaying* a signed message

=== Non-repudiation
<non-repudiation>

- Ensures that actions or messages cannot be disavowed after the fact

- Properly implemented digital signature schemes can protect it

- Precise context must be included in the signature to be effective

=== Threat modeling frameworks: STRIDE
<threat-modeling-frameworks-stride>

Flip side of the security properties:

- *Spoofing*: Unauthorized use of credentials

- *Tampering*: Unauthorized modification of information

- *Repudiation*: Performing unauthorized actions that cannot be
  detected

- *Information disclosure*: Unauthorized access to information

- *Denial of Service*: Disruption of authorized access to a
  resource

- *Elevation of privilege*: Execution of unauthorized actions

=== Threat modeling frameworks: Attack tree
<threat-modeling-frameworks-attack-tree>

- Popularized by
  #link(
    "https://www.schneier.com/academic/archives/1999/12/attack_trees.html",
  )[Bruce Schneier]

- Start with a goal, e.g. "run a program as root", this is your root
  node

- Children are ways to achieve this goal

  - recover root password

  - elevate local user privilege

  - make a sudoer run your program as root

  - replace a setuid binary on the filesystem

- Children can then have children themselves

- Attribute a cost to leaves, the cost of the parent is the min

=== Threat modeling frameworks: #link("https://linddun.org/")[LINDDUN]
<threat-modeling-frameworks-linddun>

- Privacy-focused threat model

- Developed by researchers at KU Leuven

- Suitable for GDPR/HIPAA/

  - *Linkability* Can an adversary link actions or data to a
    person?

  - *Identifiability* Can an adversary leak a person's identity?

  - *Non-repudiation* Can an adversary attribute a claim to an
    person?

  - *Detectability* Can an adversary detect a person's
    involvment?

  - *Disclosure of information* Can an adversary access personal
    data?

  - *Unawareness* Do persons know how their data is being
    processed?

  - *Non-compliance* Does the system comply with standards and
    regulation?

=== Threat modeling frameworks: PASTA
<threat-modeling-frameworks-pasta>

- Process for Attack Simultation and Threat Analysis

- Rather complex

- Works in 7 stages:

  - *Definition of objectives*

  - *Definition of technical scope*

  - *System decomposition*

  - *Threat analysis*

  - *Vulnerability analysis*

  - *Attack modeling*

  - *Impact analysis*

=== Which methodology to choose?
<which-methodology-to-choose>

- It is not necessary to follow one

- Any Threat Model is better than no Threat Model

- These frameworks are mnemonic devices:

  - A Threat Model helps to be exhaustive

  - The one forgotten threat might be the one that is exploited

  - But they also help define scope

- Try one, and adapt it to your needs

== Cryptography basics
<cryptography-basics>

=== Cryptography basics
<cryptography-basics-1>

- Various types of algorithms can be used to secure sensitive data

  - Cryptographic hash functions produce a message digest

  - Encryption algorithms allow the transformation of plain-text data
    into unintelligible data

    - Symmetric cryptography uses the same key to encrypt and decrypt
      data

    - Asymmetric cryptography uses a different key to encrypt and
      decrypt data

- Real world protocols will combine different algorithms from several
  types

== Cryptographic hash function
<cryptographic-hash-function>

=== Cryptographic hash function
<cryptographic-hash-function-1>

- Hash functions map data of arbitrary size to a known-size digest

- Cryptographic hash functions are suited for cryptographic operations:

  - Generally used for message authentication, digital signatures or
    password hashing

- Specific requirements on cryptographic hash functions:

  - Finding an input message that generates a given hash is unfeasible

  - For random input data, each possible hash is equally probable

  - Avalanche effect: small changes on the input produce a completely
    different output

- Popular algorithms: MD5, SHA-1, Whirlpool, SHA-2, SHA-3 (Keccak).

- SHA-2 and SHA-3 are the most suited for new products

  - TLS 1.3 mostly uses SHA-256 and SHA-384

#align(center, [#image("cryptographic-hash-function.pdf", width: 80%)])

== Symmetric encryption
<symmetric-encryption>

=== Symmetric encryption
<symmetric-encryption-1>

- Simplest form of encryption

- Encryption and decryption algorithms use the same key

- Encryption and decryption algorithm may differ

- Historical algorithms: Caesar cipher, Enigma machine, ROT13, XOR

- Previously popular algorithms: DES, RC4, Blowfish, and Twofish

- Nowadays, AES is the most widespread algorithm

#v(0.5em)

#align(center, [#image("symmetric_encrypt.pdf", width: 80%)])

=== AES: Advanced Encryption Standard
<aes-advanced-encryption-standard>

- NIST specification from 2001

- Based on Rijndael algorithm, developed by Joan Daemen and Vincent
  Rijmen

- Block sizes 128 bits

- Key sizes of 128, 192, or 256 bits

- Used in a virtually all up-to-date protocols relying on symmetric
  encryption

- Low RAM and CPU requirements, can easily be hardware accelerated

=== Block Cipher Modes of Operation
<block-cipher-modes-of-operation>

- Most symmetric encryption algorithms operate on blocks of a fixed size

  - To encrypt longer data, the data must first be split in as many
    blocks as needed

  - When encrypting multiple blocks with the same key, some randomness
    must be introduced, otherwise input patterns might be identifiable
    in the output.
    #align(center, [
      #align(center)[
        #box(image("Tux.pdf", width: 10%))#box(image(
          "Tux_encrypted_ecb.png",
          width: 10%,
        ))
      ]
      #text(size: 13pt)[
        An image and its encryption in ECB mode] \
      #text(size: 10pt)[
        Larry Ewing, Simon Budig, Garrett LeSage, CC0:
        #link("https://en.wikipedia.org/wiki/File:Tux.svg") \
        RFL890, CC0:
        #link(
          "https://en.wikipedia.org/wiki/File:Tux_encrypted_ecb.png",
        )[https://en.wikipedia.org/wiki/File:Tux_encrypted_ecb.png]]
    ])

- Additionally, we often want protection from data modification by third
  parties and replay attacks

- Modes of operation allow to securely chain blocks together

=== Block Cipher Modes of Operation Examples (1)
<block-cipher-modes-of-operation-examples-1>
#text(size: 18pt)[
  - Modes ensuring data confidentiality:
    #text(size: 16pt)[
      - CBC: Cipher block chaining
        #[
          #set list(spacing: 0.5em)
          - Input of each block is XORed with the output of the previous block

          - The input of the first block is XORed with either a deterministic
            initialization vector or a random one, which is shared along with
            the encrypted data.
        ]
      - CTR: Counter
        #[
          #set list(spacing: 0.5em)
          - An incrementing value is encrypted

          - This encrypted value is XORed with the input block to generate
            encrypted data

          - No dependency between blocks: encryption can be parallelized,
            random blocks can be modified

          - The initial counter value is derived from a nonce, which should be
            unique for each message encrypted with the same key
        ]
    ]
]
#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 30pt,
  [

    #text(size: 12pt)[
      #align(center)[
        #align(center, [#image("CBC_encryption.pdf", width: 90%)])
        WhiteTimberwolf, Public domain: \
        #link(
          "https://commons.wikimedia.org/wiki/File:CBC_encryption.svg",
        )[https://commons.wikimedia.org/wiki/File:CBC_encryption.svg]
      ]]
  ],
  [

    #text(size: 12pt)[
      #align(center)[
        #align(center, [#image("CTR_encryption_2.pdf", width: 90%)])
        WhiteTimberwolf, Public domain: \
        #link(
          "https://commons.wikimedia.org/wiki/File:CTR_encryption_2.svg",
        )[https://commons.wikimedia.org/wiki/File:CTR_encryption_2.svg]
      ]]
  ],
)

=== Block Cipher Modes of Operation Examples (2)
<block-cipher-modes-of-operation-examples-2>

- Modes ensuring data authentication:

  - CBC-MAC: Cipher block chaining message authentication code

    - Reuses the CBC mechanism

    - All blocks are chained: the output of the last block depends on
      all preceding blocks, the key, and the initialization vector

    - This last block output is the CBC-MAC value

    - CBC-MAC can be sent with the message, allowing receiver to verify
      data integrity
    #text(size: 11pt)[
      #align(center, [#image("CBC-MAC_structure.pdf", width: 40%)
        Benjamin D. Esham, Public domain:
        #link(
          "https://commons.wikimedia.org/wiki/File:CBC-MAC_structure_(en).svg",
        )[https://commons.wikimedia.org/wiki/File:CBC-MAC_structure_(en).svg]
      ])]

  - In most situations, keys should not be reused between
    confidentiality and authentication modes, at the risk of leaking
    part of it.

=== Block Cipher Modes of Operation Examples (2)
<block-cipher-modes-of-operation-examples-2-1>

- Modes ensuring data authentication and confidentiality:

  - CCM: Counter with cipher block chaining message authentication code

    - Relies on both CTR and CBC-MAC

    - Allows both encryption and authentication in one operation, with a
      single key and a single nonce.

  - GCM: Galois/Counter Mode

    - Relies on both CTR and Galois field multiplication

    - Also allows both encryption and authentication in one operation,
      with a single key and a single initialization vector.

== Asymmetric cryptography
<asymmetric-cryptography>

=== Asymmetric cryptography
<asymmetric-cryptography-1>

- Encryption and decryption use a pair of distinct but related keys

- Relies on one-way mathematical functions

- A public key is used to encrypt data, a private key is used to decrypt
  them

- Can also be used to authenticate data:

  - A message signature can be generated using a data digest and the
    private key

  - The data can be verified using this signature and the public key by
    comparing the obtained digest with the data

  - If both digests match, we know the signature emitter had access to
    the private key

- This allows two parties to communicate without first sharing a secret
  key

- Popular encryption algorithms: RSA

- Popular signature algorithms: ECDSA, EdDSA

#v(0.5em)

#align(center, [#image("asymmetric_encrypt.pdf", width: 80%)])

=== RSA
<rsa>

- Created by Ron Rivest, Adi Shamir, Leonard Adleman in 1977

- Variable key size, typically 3072 or 4096 bits for new products

- Relies on the difficulty to factorize the product of two prime numbers

- Can be used both for encryption and signature generation

- Slower than symmetric encryption

- Hardware implementation is complex but possible

=== ECDSA, EdDSA
<ecdsa-eddsa>

- Elliptic Curve Cryptography is based on another mathematical concept

  - Allows smaller keys with similar security level

  - Needs a bit less CPU and memory resources

- Elliptic Curve Digital Signature Algorithm

  - Designed in 1999

  - A variant of the DSA algorithm that uses elliptic-curve cryptography

  - Typical key size of 256 or 384 bits

  - Needs a randomly generated nonce

- Edwards-curve Digital Signature Algorithm

  - Designed in 2011

  - Based on twisted Edwards curves, a family of elliptic curves

  - Ed25519 relies on SHA-512, 256-bit keys

  - Ed448 relies on SHAKE256, 456 bits keys

  - Use a deterministically generated nonce

=== Diffie-Hellman
<diffie-hellman>

#table(
  columns: (68%, 32%),
  stroke: none,
  gutter: 15pt,
  [

    - Published by Whitfield Diffie and Martin Hellman in 1976

    - A key exchange algorithm that allows two parties to jointly generate a
      key

      - Both parties will generate part of the key

      - A third party eavesdropping during the key generation would not be
        able to recreate this key

    - Provides forward secrecy

      - Communication sessions remain secret over the long term, even if a
        long-term secret key is leaked

  ],
  [

    #align(center, [#image("Diffie-Hellman_Key_Exchange.pdf", width: 75%)
      #text(size: 16.5pt)[
        Diffie-Hellman key exchange analogy] \
      #text(size: 12pt)[
        #set par(leading: 0.4em)
        A.J. Vinck, Public domain: \
        #link(
          "https://en.wikipedia.org/wiki/File:Diffie-Hellman_Key_Exchange.svg",
        )[https://en.wikipedia.org/wiki/File:Diffie-Hellman_Key_Exchange.svg]
      ]
    ])

  ],
)

== Real world use cases
<real-world-use-cases>

=== Symmetric vs asymmetric cryptographic algorithms
<symmetric-vs-asymmetric-cryptographic-algorithms>

- Symmetric and asymmetric cryptographic algorithms tend to have
  opposite advantages:

  - Symmetric algorithms:

    - Low RAM and CPU requirements

    - Can easily be hardware accelerated

    - Requires a previously and secretly exchanged key between each pair
      of peers

  - Asymmetric algorithms:

    - Hardware resources hungry

    - Each peer needs to publish only one public key.

- In practice, most protocols will rely on a combination of symmetric
  and asymmetric algorithms.

=== Typical use cases
<typical-use-cases>

- Some use cases will only need to sign data:

  - RSA, ECDSA, or EdDSA can be used

  - Typical example: secure boot

- Some use cases will only need to encrypt data:

  - AES can be used with an appropriate block cipher mode of operation

  - Typical example: disk encryption

- Secure communication protocol will use a mix of all of these:

  - RSA, ECDSA, or EdDSA for authentication

  - DH of ECDH for key exchange

  - AES for communication once the secure connection is established

  - Typical protocols: TLS, SSH, GPG…

== Understanding a TLS handshake
<understanding-a-tls-handshake>

=== The Transport Layer Security Protocol
<the-transport-layer-security-protocol>

- First proposed in 1999 by the IETF as the Secure Sockets Layer (SSL)
  protocol

- Allows servers and clients to communicate in a secure way:

  - Authenticate the peers, either server-only or both ends

  - Encrypt connection to prevent eavesdropping

- It relies on several cryptographic mechanisms, including public-key
  and symmetric encryption.

- Relies on public key certificate to verify the remote public key

=== Understanding the TLS protocol
<understanding-the-tls-protocol>

- TLS protocol is based on _records_ containing either protocol
  management data or application data.

- Two main phases:

  - A handshake phase:

    - The algorithms to use during the session are selected

    - Peers are authenticated

    - Session keys are exchanged

  - A data exchange or "Application" phase

- This is a highly simplified view: application records can be
  interleaved with connection management records, such as key
  renegotiation or alerts.

=== TLS handshake with server authentication only
<tls-handshake-with-server-authentication-only>

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [
    - Assumptions

      - Only the server is authenticated

      - This is the first time the peers connect

      - TLS version 1.3: #link("https://www.rfc-editor.org/rfc/rfc8446")

  ],
  [

    #align(center, [#image("tls_empty.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Assumptions

    - Client: Client Hello

      - Very first message, sent by the client willing to open the
        connection

      - Contains:

        - The client protocol version

        - A 32 bytes random number

        - The list of supported symmetric cipher suites (e.g.,
          `AES_128_CCM`, `CHACHA20_POLY1305`)

        - A list of supported mechanisms for key exchange and their
          associated values (e.g., Diffie-Hellman with client public
          parameters).

  ],
  [

    #align(center, [#image("tls_client_hello.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Assumptions

    - Client: Client Hello

    - Server: Server Hello

      - Server reply agreeing on the configuration to use

      - Contains:

        - The selected protocol version (e.g., TLS 1.3)

        - A 32 bytes random number

        - The selected symmetric cipher suites, e.g. `AES_128_CCM`

        - One of the key exchange mechanisms offered by the client and its
          associated values (e.g., Diffie-Hellman with server public
          parameters).

  ],
  [

    #align(center, [#image("tls_server_finish.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Assumptions

    - Client: Client Hello

    - Server: Server Hello

    - Server: Certificate

      - Provides the server certificate

    - Server: Certificate Verify

      - Provides a proof the server owns the corresponding private key

      - Contains:

        - A signature of all previous handshake messages

      - Algorithms depend on the certificate, e.g. ECDSA

  ],
  [

    #align(center, [#image("tls_server_finish.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Assumptions

    - Client: Client Hello

    - Server: Server Hello

    - Server: Certificate

    - Server: Certificate Verify

    - Server: Finished

      - Confirms the handshake step is done from the server side: the client
        can now send Application data

      - Contains:

        - A MAC covering the entire handshake (using an HMAC algorithm)

  ],
  [

    #align(center, [#image("tls_server_finish.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Assumptions

    - Client: Client Hello

    - Server: Server Hello

    - Server: Certificate

    - Server: Certificate Verify

    - Server: Finished

    - Client: Finished

      - Confirms the handshake step is done from the client side: the server
        can now send Application data

      - Contains:

        - A MAC covering the entire handshake (using an HMAC algorithm)

  ],
  [

    #align(center, [#image("tls_client_finish.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Assumptions

    - Client: Client Hello

    - Server: Server Hello

    - Server: Certificate

    - Server: Certificate Verify

    - Server: Finished

    - Client: Finished

    - Application data can then be sent between peers

      - Algorithm and operation mode has been selected during the handshake,
        e.g. `AES_128_CCM`

      - Key has been constructed from the key exchange data during the
        handshake

  ],
  [

    #align(center, [#image("tls_full.pdf", width: 100%)])

  ],
)

== Understanding Public Key Infrastructures
<understanding-public-key-infrastructures>

=== Public key certificate
<public-key-certificate>

- Certifies that a specific public key is assigned to a specific entity

- Is signed by a certificate authority (CA)

- Certificate signature can then be verified by the CA own certificate

  - This creates a chain of trust extending to a root certificate

  - Root certificates are not guaranteed by a third-party: they have to
    be known by the client

- The certificate has to follow a specific format, quite often ITU-T
  X.509 is used

- Certificates can generally be revoked: this information is not
  presented by the certificate itself but has to be retrieved by other
  means

=== Public key certificate content
<public-key-certificate-content>

- Content of the certificate will depend on its goal and the CA policy

- Common content:

  - A subject: which entities this certificate belongs to. This may be a
    machine, an individual, or an organization

  - A serial number, allowing one to uniquely identify each certificate

  - The period of validity

  - The purpose of the certificate: authenticate the entity for a
    specific service or a specific operation

  - The public key

  - The issuer (CA) and its signature

=== Public key infrastructure
<public-key-infrastructure>

- Certificates should be assigned to each entities, allowing them to
  authenticate to their peers

- These certificates should be signed by a certificate authority and
  issued to legitimate users

- The Public key infrastructure defines the organisation and processes
  governing these certificates

- PKI use case examples:

  - Establishing TLS connections, e.g. over HTTP

  - Authenticate and encrypt e-mail messages, e.g. with openPGP

  - Authenticate devices in a fleet, where the PKI is entirely managed
    by the device vendor

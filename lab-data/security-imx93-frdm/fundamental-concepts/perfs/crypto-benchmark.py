#!/usr/bin/env python3

"""RSA and AES performance comparison example."""

import os
import pathlib
import tempfile
import time
from collections.abc import Callable
from typing import BinaryIO

import click
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric.padding import MGF1, OAEP
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateKey, RSAPublicKey
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.padding import PKCS7


@click.group()
def main() -> None:
    """Create RSA and AES perfromances comparisons."""


def _rsa_op(
    fn: Callable, block_size: int, input_file: BinaryIO, output_file: BinaryIO
) -> None:
    pad = OAEP(
        mgf=MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None,
    )

    buf = input_file.read(block_size)
    while buf != b"":
        outbuf = fn(buf, pad)
        output_file.write(outbuf)
        buf = input_file.read(block_size)


#
# RSA operations
#


@main.command()
@click.argument("key_file", type=click.File("rb"))
@click.argument("input_file", type=click.File("rb"))
@click.argument("output_file", type=click.File("wb"))
def rsa_encrypt(
    key_file: BinaryIO, input_file: BinaryIO, output_file: BinaryIO
) -> None:
    """Encrypt a file using RSA algorithm."""
    key = serialization.load_pem_private_key(key_file.read(), password=None)

    assert isinstance(key, (RSAPrivateKey, RSAPublicKey))
    public_key = key.public_key() if isinstance(key, RSAPrivateKey) else key

    block_size = 446
    _rsa_op(public_key.encrypt, block_size, input_file, output_file)


@main.command()
@click.argument("key_file", type=click.File("rb"))
@click.argument("input_file", type=click.File("rb"))
@click.argument("output_file", type=click.File("wb"))
def rsa_decrypt(
    key_file: BinaryIO, input_file: BinaryIO, output_file: BinaryIO
) -> None:
    """Decrypt a file using RSA algorithm."""
    key = serialization.load_pem_private_key(key_file.read(), password=None)

    assert isinstance(key, RSAPrivateKey)

    block_size = int(key.key_size / 8)
    _rsa_op(key.decrypt, block_size, input_file, output_file)


#
# AES operations
#


def _aes_encrypt_ecb(key: bytes, input_file: BinaryIO, output_file: BinaryIO) -> None:
    cipher = Cipher(algorithms.AES(key), modes.ECB())
    encryptor = cipher.encryptor()
    padder = PKCS7(128).padder()

    chunk_size = 1024
    buf = input_file.read(chunk_size)
    while buf != b"":
        outbuf = encryptor.update(padder.update(buf))
        output_file.write(outbuf)
        buf = input_file.read(chunk_size)
    output_file.write(encryptor.update(padder.finalize()))
    output_file.write(encryptor.finalize())


def _aes_decrypt_ecb(key: bytes, input_file: BinaryIO, output_file: BinaryIO) -> None:
    cipher = Cipher(algorithms.AES(key), modes.ECB())
    decryptor = cipher.decryptor()
    unpadder = PKCS7(128).unpadder()

    chunk_size = 1024
    buf = input_file.read(chunk_size)
    while buf != b"":
        outbuf = unpadder.update(decryptor.update(buf))
        output_file.write(outbuf)
        buf = input_file.read(chunk_size)
    output_file.write(unpadder.update(decryptor.finalize()))
    output_file.write(unpadder.finalize())


def _aes_encrypt_gcm(
    key: bytes, input_file: BinaryIO, output_file: BinaryIO, iv: bytes
) -> bytes:
    cipher = Cipher(algorithms.AES(key), modes.GCM(iv))
    encryptor = cipher.encryptor()

    chunk_size = 1024
    buf = input_file.read(chunk_size)
    while buf != b"":
        outbuf = encryptor.update(buf)
        output_file.write(outbuf)
        buf = input_file.read(chunk_size)
    output_file.write(encryptor.finalize())

    return encryptor.tag


def _aes_decrypt_gcm(
    key: bytes, input_file: BinaryIO, output_file: BinaryIO, iv: bytes, tag: bytes
) -> None:
    cipher = Cipher(algorithms.AES(key), modes.GCM(iv))
    decryptor = cipher.decryptor()

    chunk_size = 1024
    buf = input_file.read(chunk_size)
    while buf != b"":
        outbuf = decryptor.update(buf)
        output_file.write(outbuf)
        buf = input_file.read(chunk_size)

    output_file.write(decryptor.finalize_with_tag(tag))


@main.command()
@click.argument("key_file", type=click.File("rb"))
@click.argument("input_file", type=click.File("rb"))
@click.argument("output_file", type=click.File("wb"))
def aes_encrypt_ecb(
    key_file: BinaryIO, input_file: BinaryIO, output_file: BinaryIO
) -> None:
    """Encrypt a file using AES algorithm, ECB mode."""
    key = key_file.read()
    _aes_encrypt_ecb(key, input_file, output_file)


@main.command()
@click.argument("key_file", type=click.File("rb"))
@click.argument("input_file", type=click.File("rb"))
@click.argument("output_file", type=click.File("wb"))
def aes_decrypt_ecb(
    key_file: BinaryIO, input_file: BinaryIO, output_file: BinaryIO
) -> None:
    """Decrypt a file using AES algorithm, ECB mode."""
    key = key_file.read()
    _aes_decrypt_ecb(key, input_file, output_file)


@main.command()
@click.argument("key_file", type=click.File("rb"))
@click.argument("input_file", type=click.File("rb"))
@click.argument("output_file", type=click.File("wb"))
@click.argument("iv_file", type=click.File("wb"))
@click.argument("tag_file", type=click.File("wb"))
def aes_encrypt_gcm(
    key_file: BinaryIO,
    input_file: BinaryIO,
    output_file: BinaryIO,
    iv_file: BinaryIO,
    tag_file: BinaryIO,
) -> None:
    """Encrypt a file using AES algorithm, GCM mode."""
    key = key_file.read()
    iv = os.urandom(16)
    iv_file.write(iv)

    tag = _aes_encrypt_gcm(key, input_file, output_file, iv)
    tag_file.write(tag)


@main.command()
@click.argument("key_file", type=click.File("rb"))
@click.argument("input_file", type=click.File("rb"))
@click.argument("output_file", type=click.File("wb"))
@click.argument("iv_file", type=click.File("rb"))
@click.argument("tag_file", type=click.File("rb"))
def aes_decrypt_gcm(
    key_file: BinaryIO,
    input_file: BinaryIO,
    output_file: BinaryIO,
    iv_file: BinaryIO,
    tag_file: BinaryIO,
) -> None:
    """Decrypt a file using AES algorithm, GCM mode."""
    key = key_file.read()
    iv = iv_file.read()
    tag = tag_file.read()

    _aes_decrypt_gcm(key, input_file, output_file, iv, tag)


#
# Benchmark
#


@main.command()
@click.argument("rsa_key_file", type=click.File("rb"))
@click.option(
    "--file-size",
    "-s",
    help="Size of the randomly generated file in MB",
    type=int,
    default=1,
)
@click.option("--keep", "-k", help="Keep temporary files", is_flag=True)
def benchmark(file_size: int, keep: bool, rsa_key_file: BinaryIO) -> None:
    """Compare RSA and AES performances."""
    with tempfile.TemporaryDirectory(
        prefix="training-benchmark-", delete=not keep
    ) as _tmpdir:
        tmpdir = pathlib.Path(_tmpdir)

        data_file = tmpdir / "data"
        rsa_enc_file = tmpdir / "data.enc.rsa"
        rsa_dec_file = tmpdir / "data.dec.rsa"
        aes_ecb_enc_file = tmpdir / "data.enc.aes_ecb"
        aes_ecb_dec_file = tmpdir / "data.dec.aes_ecb"
        aes_gcm_enc_file = tmpdir / "data.enc.aes_gcm"
        aes_gcm_dec_file = tmpdir / "data.dec.aes_gcm"

        rsa_key = serialization.load_pem_private_key(rsa_key_file.read(), password=None)

        aes_ecb_key = os.urandom(32)
        aes_gcm_key = os.urandom(32)
        aes_gcm_iv = os.urandom(12)

        assert isinstance(rsa_key, RSAPrivateKey)

        print(f"Creating temporary data file: {data_file}")
        with data_file.open("wb") as output_file:
            for _ in range(file_size):
                output_file.write(os.urandom(1024 * 1024))
        print()

        print(f"Encrypting file with RSA in {rsa_enc_file}")
        block_size = 446
        with data_file.open("rb") as input_file, rsa_enc_file.open("wb") as output_file:
            start = time.process_time()
            public_key = rsa_key.public_key()
            _rsa_op(public_key.encrypt, block_size, input_file, output_file)
            long = time.process_time() - start
            print(
                f"\tEncrypted {file_size}MB of data in {long:.2f}s: "
                f"{file_size / long:.2f}MB/s"
            )

        print(f"Decrypting file with RSA in {rsa_dec_file}")
        with (
            rsa_enc_file.open("rb") as input_file,
            rsa_dec_file.open("wb") as output_file,
        ):
            block_size = int(rsa_key.key_size / 8)
            start = time.process_time()
            _rsa_op(rsa_key.decrypt, block_size, input_file, output_file)
            long = time.process_time() - start
            print(
                f"\tDecrypted {file_size}MB of data in {long:.2f}s: "
                f"{file_size / long:.2f}MB/s"
            )
        print()

        print("AES ECB parameters:")
        print(f"\tkey: {aes_ecb_key.hex()}")
        print(f"Encrypting file with AES in ECB mode in {aes_ecb_enc_file}")
        with (
            data_file.open("rb") as input_file,
            aes_ecb_enc_file.open("wb") as output_file,
        ):
            start = time.process_time()
            _aes_encrypt_ecb(aes_ecb_key, input_file, output_file)
            long = time.process_time() - start
            print(
                f"\tEncrypted {file_size}MB of data in {long:.2f}s: "
                f"{file_size / long:.2f}MB/s"
            )

        print(f"Decrypting file with AES in ECB mode in {aes_ecb_dec_file}")
        with (
            aes_ecb_enc_file.open("rb") as input_file,
            aes_ecb_dec_file.open("wb") as output_file,
        ):
            start = time.process_time()
            _aes_decrypt_ecb(aes_ecb_key, input_file, output_file)
            long = time.process_time() - start
            print(
                f"\tDecrypted {file_size}MB of data in {long:.2f}s: "
                f"{file_size / long:.2f}MB/s"
            )
        print()

        print("AES GCM parameters:")
        print(f"\tkey: {aes_gcm_key.hex()}")
        print(f"\tIV:  {aes_gcm_iv.hex()}")
        print(f"Encrypting file with AES in GCM mode in {aes_gcm_enc_file}")
        with (
            data_file.open("rb") as input_file,
            aes_gcm_enc_file.open("wb") as output_file,
        ):
            start = time.process_time()
            aes_gcm_tag = _aes_encrypt_gcm(
                aes_gcm_key, input_file, output_file, aes_gcm_iv
            )
            long = time.process_time() - start
            print(
                f"\tEncrypted {file_size}MB of data in {long:.2f}s: "
                f"{file_size / long:.2f}MB/s"
            )
        print(f"\tTAG: {aes_gcm_tag.hex()}")

        print(f"Decrypting file with AES in GCM mode in {aes_gcm_dec_file}")
        with (
            aes_gcm_enc_file.open("rb") as input_file,
            aes_gcm_dec_file.open("wb") as output_file,
        ):
            start = time.process_time()
            _aes_decrypt_gcm(
                aes_gcm_key, input_file, output_file, aes_gcm_iv, aes_gcm_tag
            )
            long = time.process_time() - start
            print(
                f"\tDecrypted {file_size}MB of data in {long:.2f}s: "
                f"{file_size / long:.2f}MB/s"
            )
        print()


if __name__ == "__main__":
    main()

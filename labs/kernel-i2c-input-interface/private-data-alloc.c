nunchuk = devm_kzalloc(&client->dev, sizeof(struct nunchuk_dev), GFP_KERNEL);
if (!nunchuk) {
	dev_err(&client->dev, "Failed to allocate memory\n");
        return -ENOMEM;
}

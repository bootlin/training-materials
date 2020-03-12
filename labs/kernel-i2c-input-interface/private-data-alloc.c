nunchuk = devm_kzalloc(&client->dev, sizeof(struct nunchuk_dev), GFP_KERNEL);
if (!nunchuk)
        return -ENOMEM;

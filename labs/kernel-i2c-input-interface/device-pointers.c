nunchuk->i2c_client = client;
nunchuk->polled_input = polled_input;
polled_input->private = nunchuk;
i2c_set_clientdata(client, nunchuk);
input = polled_input->input;
input->dev.parent = &client->dev;

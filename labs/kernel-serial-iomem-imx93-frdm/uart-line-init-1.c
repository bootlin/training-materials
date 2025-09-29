/* --- Map UART registers and enable IPG clock --- */
serial->regs = devm_platform_ioremap_resource(pdev, 0);
if (IS_ERR(serial->regs))
    return PTR_ERR(serial->regs);

serial->clk_ipg = devm_clk_get(&pdev->dev, "ipg");
if (IS_ERR(serial->clk_ipg)) {
    ret = PTR_ERR(serial->clk_ipg);
    dev_err(&pdev->dev, "Failed to get UART IPG clock\n");
    goto disable_runtime_pm;
}

ret = clk_prepare_enable(serial->clk_ipg);
if (ret) {
    dev_err(&pdev->dev, "Failed to enable IPG clock\n");
    goto disable_runtime_pm;
}

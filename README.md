# Walrus Site Deployment Automation

Automated deployment of static websites to Walrus decentralized storage using GitHub Actions.

## 🚀 Quick Start

1. **Setup Repository Secrets**
   - Go to your repository Settings → Secrets and variables → Actions
   - Add the following secrets:
     ```
     SUI_PRIVATE_KEY: Your Sui wallet private key (base64 encoded)
     SUI_ADDRESS: Your Sui wallet address (e.g., 0x1234...)
     ```

2. **Prepare Your Site**
   - Ensure your build process outputs static files to `./dist`
   - The workflow will auto-detect and build npm projects

3. **Deploy**
   - **Automatic**: Push to `main` branch triggers deployment to testnet
   - **Manual**: Use "Actions" tab → "Deploy to Walrus" → "Run workflow"

## 📋 Manual Setup (First Time)

If you need to set up a new Sui wallet:

```bash
# Install Sui CLI
curl -fsSL https://raw.githubusercontent.com/MystenLabs/sui/main/scripts/install.sh | bash

# Create new wallet
sui client new-address ed25519

# Get your address
sui client active-address

# Export private key (for GitHub secrets)
sui keytool export --keystore-path ~/.sui/sui_config/sui.keystore --address YOUR_ADDRESS
```

## ⚙️ Configuration

The workflow uses configuration files in the `config/` directory:

- **`config/walrus-client.yaml`**: Walrus client configuration for both networks
- **`config/walrus-site.yaml`**: Site deployment settings and package addresses

These files contain public blockchain addresses and can be safely committed to your repository.

## 🌐 Deployment Options

### Networks
- **Testnet** (default): Free, for testing and development
- **Mainnet**: Production deployments (requires SUI tokens for gas)

### Storage Duration (Epochs)
- **Testnet**: 1 epoch = 2 days
- **Mainnet**: 1 epoch = 14 days
- **Default**: 5 epochs (10 days testnet / 70 days mainnet)

### Workflow Triggers

#### Automatic Deployment
```yaml
# Triggers on push to main branch
git push origin main
```

#### Manual Deployment
Use the GitHub Actions interface with custom parameters:
- **Network**: Choose testnet or mainnet
- **Epochs**: Set storage duration
- **Force Rebuild**: Override cache and rebuild

## 📊 Workflow Outputs

After successful deployment, you'll get:
- **Site URL**: Direct link to your deployed site
- **Deployment ID**: Unique identifier for this deployment
- **Storage Duration**: Confirmation of epoch setting
- **Expiration Date**: When the deployment expires

## 🔧 Advanced Configuration

### Custom Build Process
If your project doesn't use npm, modify the workflow's build steps:

```yaml
- name: Custom Build
  run: |
    # Your custom build commands here
    # Ensure output goes to ./dist
```

### Gas Budget
For mainnet deployments, you can adjust gas settings in `config/walrus-site.yaml`:

```yaml
general:
  gas_budget: 500000000  # Adjust as needed
```

## 🛡️ Security Notes

- ✅ Configuration files contain only public addresses
- ✅ Private keys are stored securely in GitHub Secrets
- ✅ Testnet deployments use free faucet tokens
- ⚠️ Mainnet deployments require real SUI tokens

## 🐛 Troubleshooting

### Common Issues

**"./dist directory not found"**
- Ensure your build process creates a `./dist` directory
- Check that build commands in the workflow match your project

**"SUI_PRIVATE_KEY and SUI_ADDRESS secrets must be set"**
- Add the required secrets in repository settings
- Ensure private key is base64 encoded

**"Insufficient balance"**
- For testnet: Workflow automatically requests from faucet
- For mainnet: Fund your wallet with SUI tokens

**Deployment fails with gas errors**
- Check wallet balance: `sui client gas`
- For testnet: Workflow will auto-fund
- For mainnet: Add more SUI tokens to your wallet

### Getting Help

1. Check the [Walrus documentation](https://docs.walrus.site/)
2. Review workflow logs in the Actions tab
3. Verify your configuration files match the expected format

## 📚 What is Walrus?

Walrus is a decentralized storage network built on the Sui blockchain. It provides:
- **Decentralized hosting**: No single point of failure
- **Cost-effective storage**: Pay once for epoch-based storage
- **Permanent URLs**: Your content remains accessible via consistent URLs
- **Blockchain security**: Leverages Sui's security guarantees

Sites deployed to Walrus are accessible via:
- **Testnet**: `https://your-id.buildonwalrus.dev`
- **Mainnet**: `https://your-id.walrus.site`

---

*This automation workflow transforms the manual deployment process into a seamless CI/CD pipeline, making it easy to deploy and maintain your static sites on Walrus.*
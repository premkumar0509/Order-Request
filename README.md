
<p align="center"><h1 align="center">ORDER-REQUEST</h1></p>
<p align="center">
	<em><code>❯ AL Extension for Business Central</code></em>
</p>
<p align="center">
	<img src="https://img.shields.io/github/license/premkumar0509/Order-Request?style=default&logo=opensourceinitiative&logoColor=white&color=0080ff" alt="license">
	<img src="https://img.shields.io/github/last-commit/premkumar0509/Order-Request?style=default&logo=git&logoColor=white&color=0080ff" alt="last-commit">
	<img src="https://img.shields.io/github/languages/top/premkumar0509/Order-Request?style=default&color=0080ff" alt="repo-top-language">
	<img src="https://img.shields.io/github/languages/count/premkumar0509/Order-Request?style=default&color=0080ff" alt="repo-language-count">
</p>
<br>

## 🔗 Table of Contents

- [📍 Overview](#-overview)
- [👾 Features](#-features)
- [📁 Project Structure](#-project-structure)
  - [📂 Project Index](#-project-index)
- [🚀 Getting Started](#-getting-started)
  - [☑️ Prerequisites](#-prerequisites)
  - [⚙️ Installation](#-installation)
  - [🤖 Usage](#🤖-usage)
  - [🧪 Testing](#🧪-testing)
- [📌 Project Roadmap](#-project-roadmap)
- [🔰 Contributing](#-contributing)
- [🎗 License](#-license)
- [🙌 Acknowledgments](#-acknowledgments)

---

## 📍 Overview

The **Order Request Management** extension for Business Central automates order intake by syncing data from **Google Forms** and **Microsoft Forms** into Business Central.  
It creates **customers & sales orders**, and sends **HTML order confirmation emails** automatically.  
This project eliminates manual entry, ensures real-time confirmations, and improves overall efficiency in sales operations.  

---

## 👾 Features

- 🔄 **Form Integration**  
  - Sync order data from **Google Sheets (CSV export)**.  
  - Sync order data from **Microsoft Excel Online**.  

- 📝 **Order Management**  
  - Avoids duplicates by validating `Order ID`.  
  - Creates **customers** if they don’t exist.  
  - Generates **Sales Orders** with item & quantity details.  

- 📧 **Email Automation**  
  - Sends personalized **HTML confirmation emails** with order & customer numbers.  
  - Tracks email status and logs errors if delivery fails.  

- ⚙️ **Configurable Setup**  
  - Configure sheet/Excel URLs.  
  - Define posting groups & customer number series.  

---



## 🚀 Getting Started

### ☑️ Prerequisites
- Microsoft Dynamics 365 Business Central (Cloud/SaaS or On-Prem).
- AL Language extension for Visual Studio Code.
- Proper permissions to deploy extensions.

---

### ⚙️ Installation

#### From Source
```sh
git clone https://github.com/premkumar0509/Order-Request
cd Order-Request
```

Then open in VS Code and deploy the extension to your BC sandbox using `Ctrl + F5`.

---

## 📁 Project Structure

```sh
└── Order-Request/
    ├── Order Request Response.docx
    ├── OrderRequest.csv
    ├── PK_Order Request_1.0.0.0.app
    ├── PermissionSet_50010_OrderRequest.al
    ├── Repos
    │   ├── Codeunit
    │   ├── Logo
    │   ├── Page
    │   └── Table
    ├── app.json
    └── extensionsPermissionSet.xml
```

## 🤖 Usage

- Configure URLs & posting groups in **Order Request Setup**.  
- Run **Sync Order Request** to fetch data from forms.  
- Open **Order Request Dashboard** to view requests.  
- Use **Make Order** action to create sales orders.  
- Run **Send Order Confirmation Mail** to notify customers.  

---

## 🧪 Testing

1. Create a sample **Google/Microsoft Form** with order entries.  
2. Sync into Business Central and verify customer/order creation.  
3. Check that **confirmation emails** are received.  

---

## 📌 Project Roadmap

- [x] Google Form integration (CSV)  
- [ ] Microsoft Form integration (Excel Online)  
- [x] Sales order auto-creation  
- [x] Email confirmation system  
- [x] Power BI dashboard integration  
- [ ] Teams notification after order confirmation  

---

## 🎗 License

This project is protected under the **MIT License**.  

---

## 🙌 Acknowledgments

- **Microsoft Docs** – AL Language & Business Central Development  
- Community blogs and forums for integration ideas  
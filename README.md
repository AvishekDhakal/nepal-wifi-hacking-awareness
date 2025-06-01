# Nepal WiFi Hacking Awareness Toolkit

This was a project I demonstrated in my college TechExpo to show how attackers can easily target WiFi users using deauthentication attacks and fake access points. 
It is focused on Nepalese ISPs to make the awareness more relatable to local users.

---

## How It Works

The toolkit uses tools like `hostapd-wpe`, `dnsmasq`, and `apache2` to:

- Deauthenticate users from real WiFi
- Set up a fake access point (with common Nepalese ISP names)
- Serve a fake login page (similar to ISP captive portals)
- Collect login attempts for educational demonstration

The attack simulates how someone could steal credentials using simple techniques and open-source tools.

---

## Features

- Deauthentication attack to force users to disconnect
- Fake AP broadcasting popular SSIDs (e.g., Worldlink, Vianet)
- ISP-styled login page served via Apache
- One-click setup script
- Portable and easy to use on Kali/Parrot OS

---

## Who Is This For?

- Cybersecurity students in Nepal
- Ethical hackers and red teamers
- General users interested in WiFi security awareness
- Trainers running awareness workshops

---

## Quick Start

```bash
chmod +x captive-portal.sh
./captive-portal.sh





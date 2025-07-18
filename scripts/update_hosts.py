import requests
import re
from datetime import datetime

# Function to download content from a URL
def download_hosts(url):
    try:
        response = requests.get(url)
        return response.text
    except Exception as e:
        print(f"Error downloading hosts from {url}: {str(e)}")
        return None

# Function to remove duplicate lines from the hosts file
def remove_duplicate_lines(hosts_content):
    lines_seen = set()
    cleaned_hosts = ""
    for line in hosts_content.split("\n"):
        if line not in lines_seen:
            cleaned_hosts += line + "\n"
            lines_seen.add(line)
    return cleaned_hosts

# Function to remove commented lines from the hosts file
def remove_commented_lines(hosts_content):
    cleaned_hosts = ""
    for line in hosts_content.split("\n"):
        if "#" not in line:
            cleaned_hosts += line + "\n"
    return cleaned_hosts

# Function to remove lines with specific addresses from the hosts file
def remove_blocked_hosts(hosts_content, blocked_hosts):
    hosts = ""
    # Convert blocked_hosts patterns with '*' to regex patterns
    regex_patterns = [re.compile(re.escape(blocked_host).replace(r'\*', '.*')) for blocked_host in blocked_hosts]
    
    for line in hosts_content.split("\n"):
        parts = line.split()
        # Check if the line contains at least two parts and the second part matches any blocked pattern
        if parts and len(parts) >= 2 and not any(pattern.search(parts[1]) for pattern in regex_patterns):
            hosts += line + "\n"
    return hosts

# Function to add a custom header to the hosts file
def add_header(hosts_content, header):
    return header + "\n" + hosts_content

# Function to add new lines to the end of the hosts file
def add_new_lines(hosts_content, new_lines):
    return hosts_content + "\n".join(new_lines)

# List of URLs for the host lists
host_lists = [
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
    "https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/malware.hosts?ref_type=heads",
    "https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/trackers.hosts?ref_type=heads",
    "https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt",
    "https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts",
    "https://o0.pages.dev/Pro/hosts.txt",
    "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/ultimate.txt"
]

# List of addresses to be removed
blocked_addresses = [
    # AliExpress
    "alicdn.com",
    # Adobe
    "sstats.adobe.com",
    "assest.adobedtm.com",
    # Adult Swim
    "ad.auditude.com",
    "bea4.v.fwmrm.net",
    "geo.ngtv.io",
    "sb.scorecardresearch.com",
    "sstats.adultswim.com",
    # Amazon / Prime Video
    "amazon-adsystem.com",
    "aan.amazon.com",
    "api.us-east-1.aiv-delivery.net",
    "device-metrics*.amazon.com",
    # Discover
    "api.mixpanel.com",
    "api.radar.io",
    "branch.io",
    "datadoghq.com",
    "discover.com",
    "tt.omtrdc.net",
    "report.dfs.glassboxdigital.io",
    # Epic Games
    "eulatracking-public-service-prod.ol.epicgames.com",
    "delivers.dtignite.com",
    # Gupy
    "email.gupy.com.br",
    "email.inbound.gupy.com.br",
    # Microsoft
    "live.com",
    "microsoft.com",
    "microsoftonline.com",
    # Other "APIS"
    "codepush.appcenter.ms",
    "dpm.demdex.net",
    "sentry.io",
    # Google
    "googleapis.com",
    "googleadservices.com",
    "s.youtube.com",
    # Groq AI
    "web.stytch.com",
    "groq.com",
    # Meta
    "edge.mqtt.facebook.com",
    "graph.facebook.com",
    "b-graph.facebook.com",
    "mqtt-mini.facebook.com",
    "web.facebook.com",
    "graph.instagram.com",
    # NordVPN
    "launches.appsflyer.com",
    # OnePlus
    "com-service-us-04.allwnos.com",
    "com-service-us-05.allwnos.com",
    "com-service-us-07.allwnos.com",
    "com-service-us-08.allwnos.com",
    # Samsung Apps
    "samsungrs.com",
    "samsungosp.com",
    "samsungcloud.com",
    "samsungapps.com",
    "samsung-gamelauncher.com",
    # Supercell
    "supercell.com",
    # Streaming
    "tidal.com",
    "spotify.app.link",
    # Twitter / X
    "t.co",
    # Sites
    "html-load.com",
    # Whatsapp
    "whatsapp.com",
    "whatsapp.net"
]

# New lines to add to the end of the hosts file
# Exemple: 0.0.0.0 ads.google.com
# I don't think it's necessary, since hosts don't cover almost everything
new_lines = [
"""
# The lines below are added directly to the module

0.0.0.0 tigr1234566.github.io
0.0.0.0 serviceaonlineasiausaosiauuaaosmanagsoaisoas.es
"""]

# Custom header
header = f"""

   ███████╗███████╗███████╗███╗   ██╗ ██████╗ 
   ╚══███╔╝██╔════╝██╔════╝████╗  ██║██╔═══██╗
     ███╔╝ █████╗  █████╗  ██╔██╗ ██║██║   ██║
    ███╔╝  ██╔══╝  ██╔══╝  ██║╚██╗██║██║   ██║
   ███████╗███████╗███████╗██║ ╚████║╚██████╔╝
   ╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝ ╚═════╝   

"""

# Download and concatenate the hosts from the lists
hosts_content = ""
for url in host_lists:
    content = download_hosts(url)
    if content:
        hosts_content += content + "\n"

# Remove duplicate lines
cleaned_hosts = remove_duplicate_lines(hosts_content)

# Remove commented lines
cleaned_hosts = remove_commented_lines(cleaned_hosts)

# Remove blocked hosts
hosts = remove_blocked_hosts(cleaned_hosts, blocked_addresses)

# Add custom header
hosts_with_header = add_header(hosts, header)

# Add new lines
hosts_with_new_lines = add_new_lines(hosts_with_header, new_lines)

# Write the updated file
with open("../etc/hosts", "w") as file:
    file.write(hosts_with_new_lines)

print("Hosts file generated successfully!")

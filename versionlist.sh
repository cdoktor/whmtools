# === Color Definition ===
BLUE='\e[1;34m'
GREEN='\e[1;32m'
GRAY='\e[0;37m'
NC='\e[0m' # No Color

divider="${GRAY}----------------------------------------${NC}"

echo -e "${BLUE}Hostname:${NC}"
echo -e "${GREEN}$(hostname)${NC}"
echo -e "$divider"

echo -e "${BLUE}IP Address:${NC}"
echo -e "${GREEN}$(ip -4 addr show | awk '/inet / && $2 !~ /^127/ {print $2}' | cut -d/ -f1)${NC}"
echo -e "$divider"

echo -e "${BLUE}OS:${NC}"
echo -e "${GREEN}$(cat /etc/redhat-release)${NC}"
echo -e "$divider"

echo -e "${BLUE}cPanel:${NC}"
echo -e "${GREEN}$(cat /usr/local/cpanel/version)${NC}"
echo -e "$divider"

echo -e "${BLUE}Imunify:${NC}"
rpm -qa | egrep 'imunify360-firewall|imunify-ui|imunify-antivirus|imunify-core' | grep -v cpanel | \
while read line; do
    echo -e "${GREEN}${line}${NC}"
done
echo -e "$divider"

echo -e "${BLUE}JetBackup Base:${NC}"
rpm -qa | grep jetbackup5-base | while read line; do
    echo -e "${GREEN}${line}${NC}"
done
echo -e "$divider"

echo -e "${BLUE}JetBackup cPanel:${NC}"
rpm -qa | grep -E 'jetbackup[0-9]+-cpanel' | while read line; do
    echo -e "${GREEN}${line}${NC}"
done

import http.client
import re
import urllib

def main():
    Resource = "?filter_active=0&filter_cat=0&show_tab=postings"
    Connection = http.client.HTTPSConnection("accounts.craigslist.org/login/home", 443, timeout=1)
    Connection.request("GET", Resource)
    Response = Connection.getresponse()
    Code = parse(Response)
    params = urllib.parse.urlencode({'action': "renew", 'crypt': Code, 'go': 'Renew this Posting'})
    headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain"}
    Connection.request("POST", Resource, params, headers)

def parse(Response):
    formArray = []
    formArray = re.findall(r"form.*?form",str(Response.read()))
    for line in formArray:
        if line.find("crypt") != -1:
            formArray = re.findall(r"value.*?\".*?\"", line)
    for line in formArray:
        if len(line) > 40:
            value = line
    return value.split("\"")[1]

main()

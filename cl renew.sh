#!/usr/bin/env node

var links = document.querySelectorAll('a[title="renew"]');
for (var i = 0; i < links.length; i++) {
    links[i].click();
}


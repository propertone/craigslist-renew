#!/usr/bin/env node

var links = document.getElementsByTagName("a");
for (var i = 0; i < links.length; i++) {
    if (links[i].title === "renew")
        links[i].click();
}


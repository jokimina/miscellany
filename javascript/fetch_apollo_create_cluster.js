cluser = "singapore";
["app1", "app2", "app3"].forEach(app => {
    fetch(`http://apollo-service/apps/${app}/envs/PRO/clusters`, {
            "credentials": "include",
            "headers": {
                "Content-Type": "application/json"
            },
            "referrer": "http://apollo-service/cluster.html?",
            "referrerPolicy": "no-referrer-when-downgrade",
            "body": `{"name":"${cluser}","appId":"${app}"}`,
            "method": "POST",
            "mode": "cors"
        })
        .then(function(res) {
            if (res.ok) {
                res.json().then(function(data) {
                    console.log(data.entries);
                });
            } else {
                console.log("Looks like the response wasn't perfect, got status", res.status);
            }
        }, function(e) {
            console.log("Fetch failed!", e);
        });
})

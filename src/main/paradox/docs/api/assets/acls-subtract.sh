curl -XPATCH -H "Content-Type: application/json" "https://nexus.example.com/v1/acls/org1?rev=2" -d \
'{
  "@type": "Subtract",
  "acl": [
    {
      "permissions": [
        "read"
      ],
      "identity": {
        "group": "a-group",
        "realm": "myrealm"
      }
    }
  ]
}'
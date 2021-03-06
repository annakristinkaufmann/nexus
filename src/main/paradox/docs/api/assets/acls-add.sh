curl -XPUT -H "Content-Type: application/json" "https://nexus.example.com/v1/acls/org1" -d  \
'{
  "acl": [
    {
      "permissions": [
        "read"
      ],
      "identity": {
        "realm": "myrealm",
        "group": "a-group"
      }
    },
    {
      "permissions": [
        "read",
        "write"
      ],
      "identity": {
        "realm": "realm",
        "group": "some-group"
      }
    },
    {
      "permissions": [
        "acls/read",
        "acls/write"
      ],
      "identity": {
        "realm": "realm",
        "subject": "alice"
      }
    }
  ]
}'
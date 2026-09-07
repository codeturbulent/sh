curl --location 'https://us-central1-jiva-flutter.cloudfunctions.net/assignUserPlan' \
--header 'x-api-key: <Apikey>' \
--header 'Content-Type: application/json' \
--data-raw '{
"emails": [
"rabaridhrija@gmail.com" 
],
"plan_id": "jivasub_3",
"expiresAt": "2026-10-22T08:31:48+0000"
}'

#it just accept one email at once plan ids are [plan id : jiva_free jivasub_1 jivasub_2 jivasub_3]

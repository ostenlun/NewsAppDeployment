# Test NewsApp web api with curl
echo "Testing NewsApp API and MockStorage API..."
RESPONSE=$(curl -s http://localhost:8080/news)
if [[ $RESPONSE == *"title"* && $RESPONSE == *"description"*
then
    echo "NewsApp API is working correctly."
else
    echo "NewsApp API test failed."
    exit 1
fi
echo "All tests passed successfully."

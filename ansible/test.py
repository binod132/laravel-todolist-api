import requests

# Define the URL for testing
url = "https://jsonplaceholder.typicode.com/todos/1"

try:
    # Send a GET request to the URL
    response = requests.get(url)
    
    # Check if the request was successful
    if response.status_code == 200:
        print("Request successful!")
        print("Response JSON data:", response.json())
    else:
        print(f"Request failed with status code: {response.status_code}")

except requests.exceptions.RequestException as e:
    print(f"An error occurred: {e}")


from datetime import timedelta
import requests, json
from bs4 import BeautifulSoup as bs
import sys

url = sys.argv[1]
token1 = open('.splrc/token.txt', 'r')
token = "'Bearer ' + token1"
token1.close()

api =  f"https://api.spotify.com/v1/tracks/{url[31:url.find('?')]}"
rq = requests.get(api, headers={"authorization":token})

if str(rq) == "<Response [400]>" or "<Response [401]>":
	readCookieFile = open('.splrc/cookie.txt', 'r')
	loadInJson = json.loads(readCookieFile.read())
	readCookieFile.close()
	cookie = ''
	for name in loadInJson:
		cookie += str(f"{name['name']}={name['value']}; ")
	cookie = cookie[:-2]
	r = requests.get("https://open.spotify.com", headers={"cookie":cookie}).text
	r = bs(r, 'html.parser').script.text
	q = json.loads(r)
	open('token.txt', 'w').write(q['accessToken'])
	token = f"Bearer {q['accessToken']}"
#	api =  f"https://api.spotify.com/v1/tracks/{url[31:url.find('?')]}"
#	rq = requests.get(api, headers={"authorization":token})
	
#datainjson = json.loads(rq.text)
#artist_title = ''
#for artists in datainjson['artists']:
#	artist_title += f"{artists['name']}, "
#track_title = datainjson['name']
#artist_title = artist_title[:-2]
	
url = f"https://spclient.wg.spotify.com/color-lyrics/v2/track/{url[31:url.find('?')]}/image/https%3A%2F%2Fi.scdn.co%2Fimage%2Fab67616d0000b2735da9fa8f83aebf5cbe7db12a?format=json&vocalRemoval=false&market=from_token"

rp = requests.get(url, headers={"authorization":token, "User-Agent":"Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Mobile Safari/537.36", "app-platform":"WebPlayer"})

lrc = '[00:00.000]\n'
data = json.loads((rp.text))
for startTimeMs in data['lyrics']['lines']:
	sec = int(startTimeMs['startTimeMs'])/1000
	td = str(timedelta(seconds=sec))
	if '.' in td:
		lrc += str(f"[{td[2:-3]}]{startTimeMs['words']}\n")
	else:
		lrc +=  str(f"[{td[2:]}]{startTimeMs['words']}\n")

print(lrc)

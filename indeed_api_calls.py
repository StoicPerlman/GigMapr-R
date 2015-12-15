from indeed import IndeedClient
from math import floor
import re

PUBLISHER_ID = FILL_ME_IN

States = {
        'AK': 'Alaska',
        'AL': 'Alabama',
        'AR': 'Arkansas',
        'AZ': 'Arizona',
        'CA': 'California',
        'CO': 'Colorado',
        'CT': 'Connecticut',
        'DE': 'Delaware',
        'FL': 'Florida',
        'GA': 'Georgia',
        'HI': 'Hawaii',
        'IA': 'Iowa',
        'ID': 'Idaho',
        'IL': 'Illinois',
        'IN': 'Indiana',
        'KS': 'Kansas',
        'KY': 'Kentucky',
        'LA': 'Louisiana',
        'MA': 'Massachusetts',
        'MD': 'Maryland',
        'ME': 'Maine',
        'MI': 'Michigan',
        'MN': 'Minnesota',
        'MO': 'Missouri',
        'MS': 'Mississippi',
        'MT': 'Montana',
        'NC': 'North Carolina',
        'ND': 'North Dakota',
        'NE': 'Nebraska',
        'NH': 'New Hampshire',
        'NJ': 'New Jersey',
        'NM': 'New Mexico',
        'NV': 'Nevada',
        'NY': 'New York',
        'OH': 'Ohio',
        'OK': 'Oklahoma',
        'OR': 'Oregon',
        'PA': 'Pennsylvania',
        'RI': 'Rhode Island',
        'SC': 'South Carolina',
        'SD': 'South Dakota',
        'TN': 'Tennessee',
        'TX': 'Texas',
        'UT': 'Utah',
        'VA': 'Virginia',
        'VT': 'Vermont',
        'WA': 'Washington',
        'WI': 'Wisconsin',
        'WV': 'West Virginia',
        'WY': 'Wyoming'
}

def Search(query, location, limit=10, start=0):
    client = IndeedClient(publisher=PUBLISHER_ID)
    params = {
        'q': query,
        'l': location,
        'limit': limit,
        'start': start,
        'userip': "1.2.3.4",
        'useragent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)"
    }
    search_response = client.search(**params)
    return search_response


def GetEachStateCount(query):
    results = dict()
    for state in States.values():
        state = state.lower()
        results[state] = GetStateCount(query, state)
    return results


def GetStateCount(query, state):
    search_response = Search(query, state, 0, 0)
    return search_response['totalResults']


def GetListings(query, location):
    # all text for word cloud
    fullText = ''
    count = GetStateCount(query, location)
    jobs = []
    if count > 0:
        totalPages = floor(count / 25)
        currentPage = 0
        MAX_API_CALS = 300
        while currentPage <= totalPages and currentPage < MAX_API_CALS:
            search_response = Search(query, location, 25, 25 * currentPage)
            for job in search_response['results']:
                # clean title and snippet
                job["snippet"] = RemoveTages(job["snippet"])
                fullText += FillAbbr(RemoveSpecial(job["snippet"])) + ' '
                fullText += FillAbbr(RemoveSpecial(job["jobtitle"])) + ' '

                # remove unwanted data
                job.pop('jobkey', None)
                job.pop('onmousedown', None)
                job.pop('source', None)
                job.pop('indeedApply', None)
                job.pop('formattedRelativeTime', None)
                job.pop('formattedLocation', None)
                job.pop('formattedLocationFull', None)
                job.pop('sponsored', None)
                job.pop('url', None)
                job.pop('noUniqueUrl', None)
                job.pop('expired', None)
                job.pop('country', None)
                job.pop('snippet', None)
                job.pop('jobtitle', None)
                jobs.append(job)
            currentPage += 1
    return {'text': fullText, 'jobs': jobs}


def RemoveTages(text):
    # remove HTML tags
    return re.sub('<[^<]+?>', '', text)

def RemoveSpecial(text):
    # only preserve ISO/IEC recognized languages
    tmp = re.compile(re.escape('c#'), re.IGNORECASE)
    text = tmp.sub('CZ', text)
    tmp = re.compile(re.escape('c++'), re.IGNORECASE)
    text = tmp.sub('CZZ', text)
    tmp = re.compile(re.escape('.net'), re.IGNORECASE)
    text = tmp.sub('ZNET', text)

    # remove non alpha or non num or non space
    text = re.sub('[^a-zA-Z0-9 ]', ' ', text)
    # remove double, triple, etc spaces and spaces at end
    text = " ".join(text.split())
    text = text.strip()

    # put languages back
    text = text.replace('CZZ', ' C++ ')
    # r text mining has an issue with # so switch to sharp here and replace # in r
    text = text.replace('CZ', ' CSharp ')
    text = text.replace('ZNET', ' .NET ')

    return text

def FillAbbr(text):
    # sub some common abbreviations
    tmp = re.compile(re.escape(' jr '), re.IGNORECASE)
    text = tmp.sub(' junior ', text)
    tmp = re.compile(re.escape(' sr '), re.IGNORECASE)
    text = tmp.sub(' senior ', text)
    return text

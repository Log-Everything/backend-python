# Copyright 2020 Jacek Marchwicki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import flask
from flask import Flask
from google.cloud import ndb
from google.cloud.logging.client import Client
from google.cloud.logging.handlers.app_engine import AppEngineHandler
import logging


def if_localhost():
    import os
    if not "DATASTORE_EMULATOR_HOST" in os.environ:
        return False
    return "localhost" in os.environ['DATASTORE_EMULATOR_HOST']


def google_logger():
    logging_client = Client()
    return AppEngineHandler(client=logging_client)


def stdout_logger():
    import sys
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    return handler


root = logging.getLogger()
root.setLevel(logging.DEBUG)
root.addHandler(stdout_logger())
if not if_localhost():
    root.addHandler(google_logger())
db_client = ndb.Client()


class LogEntry(ndb.Model):
    title = ndb.StringProperty()
    description = ndb.StringProperty()


# oauth = flask_oauth.OAuth()
# google_login = oauth.remote_app('gitlab',
#                           base_url=secrets.GITLAB_URL,
#                           authorize_url=urlparse.urljoin(secrets.GITLAB_URL, 'oauth/authorize'),
#                           request_token_url=None,
#                           request_token_params={'response_type': 'code'},
#                           access_token_url=urlparse.urljoin(secrets.GITLAB_URL, 'oauth/token'),
#                           access_token_method='POST',
#                           access_token_params={'grant_type': 'authorization_code'},
#                           consumer_key=secrets.GTILAB_CONSUMER_KEY,
#                           consumer_secret=secrets.GTILAB_CONSUMER_SECRET)

app = Flask(__name__)


@app.route('/')
def index():
    with db_client.context():
        contact1 = LogEntry(
            title="Entry 1",
            description="ala ma kota",
        )
        contact1.put()
        query = LogEntry.query()
        titles = [c.title for c in query]
    return flask.redirect(flask.url_for('static', filename='dashboard/index.html'))
    # return flask.render_template('index.html')


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

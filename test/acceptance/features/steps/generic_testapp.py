from app import App
import requests
import json
import polling2
from behave import given, step, then


class GenericTestApp(App):

    def __init__(self, name, namespace, bindingRoot="", app_image="quay.io/redhat-developer/sbo-generic-test-app:20200923"):
        App.__init__(self, name, namespace, app_image, bindingRoot)

    def get_env_var_value(self, name):
        resp = polling2.poll(lambda: requests.get(url=f"http://{self.route_url}/env/{name}"),
                             check_success=lambda r: r.status_code in [200, 404], step=5, timeout=400)
        print(f'env endpoint response: {resp.text} code: {resp.status_code}')
        if resp.status_code == 200:
            return json.loads(resp.text)
        else:
            return None

    def check_for_404_env_var_value(self, name):
        resp = polling2.poll(lambda: requests.get(url=f"http://{self.route_url}/env/{name}"),
                             check_success=lambda r: r.status_code == 404, step=5, timeout=400)
        print(f'env endpoint response code: {resp.status_code}')
        if resp.status_code == 404:
            return True

    def get_file_value(self, file_path):
        resp = requests.get(url=f"http://{self.route_url}{file_path}")
        print(f'file endpoint response: {resp.text} code: {resp.status_code}')
        if resp.status_code == 200:
            return resp.text


@given(u'Generic test application "{application_name}" is running')
def is_running(context, application_name):
    application = GenericTestApp(application_name, context.namespace.name)
    if not application.is_running():
        print("application is not running, trying to import it")
        application.install()
    context.application = application


@given(u'Generic test application "{application_name}" is running with binding root as "{bindingRoot}"')
def is_running_with_env(context, application_name, bindingRoot):
    application = GenericTestApp(application_name, context.namespace.name, bindingRoot)
    if not application.is_running():
        print("application is not running, trying to import it")
        application.install()
    context.application = application


@step(u'The application env var "{name}" has value "{value}"')
def check_env_var_value(context, name, value):
    found = polling2.poll(lambda: context.application.get_env_var_value(name) == value, step=5, timeout=400)
    assert found, f'Env var "{name}" should contain value "{value}"'


@step(u'The env var "{name}" is not available to the application')
def check_env_var_existence(context, name):
    output = context.application.check_for_404_env_var_value(name)
    assert output, f'Env var "{name}" should not exist'


@then(u'Content of file "{file_path}" in application pod is')
def check_file_value(context, file_path):
    value = context.text.strip()
    found = polling2.poll(lambda: context.application.get_file_value(file_path) == value, step=5, timeout=400)
    assert found, f'File "{file_path}" should contain value "{value}"'

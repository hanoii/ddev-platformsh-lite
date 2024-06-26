setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-platformsh-lite
  mkdir -p $TESTDIR
  export PROJNAME=test-platformsh-lite
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  git init .
  ddev config --project-name=${PROJNAME} --project-type=php --web-environment-add=PLATFORMSH_CLI_TOKEN=notokenrightnow,PLATFORM_PROJECT=notyet
  ddev get hanoii/ddev-pimp-my-shell
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  # Do something here to verify functioning extra service
  # For now, we do nothing, unly make sure that it runs OK.
}

#@test "install from release" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "# ddev get drud/ddev-addon-template with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#  ddev get drud/ddev-addon-template
#  ddev restart >/dev/null
#  # Do something useful here that verifies the add-on
#  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
#}

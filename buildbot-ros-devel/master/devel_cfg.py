# cfg libs is only for master setup
# command scripts executed by steps don't need these libs

from buildbot.config import BuilderConfig
from buildbot.process.factory import BuildFactory
from buildbot.process.properties import Interpolate
from buildbot.steps.source.git import Git
from buildbot.steps.shell import ShellCommand, SetPropertyFromCommand
from buildbot.steps.transfer import FileUpload, FileDownload, DirectoryUpload
from buildbot.steps.trigger import Trigger
from buildbot.steps.master import MasterShellCommand
from buildbot.steps.worker import RemoveDirectory
from buildbot.schedulers import triggerable
from buildbot.plugins import util, schedulers
from buildbot.plugins import *

# private-common repo
common_repo = {
    "url" : "https://github.com/zhouchengming1/ros-private-common.git",
    "branch" : "master",
    "pkgs" : "",
}

# master use HTTPs to check, or git need ssh key
repo1 = {
    "url" : "https://github.com/zhouchengming1/catkin_test.git",
    "branch" : "master",
    "pkgs" : "",
}

# Only the build machine can get to internal repo
# So we put the build machine inside, and release to the outside machine
autogo_repo = {
    "url" : "http://gitlab.alibaba-inc.com/eric.zcm/autogo-migrate.git",
    "branch" : "master",
    "pkgs" : "xw_gs1810",
}

# source(url+branch) + build_type = builder
project1 = {
    "name" : "repo1",
    "repos" : [repo1, common_repo, autogo_repo],
    "builders" : [],
    "arch" : "amd64",
    "oscode" : "xenial",
    "distro" : "kinetic",
}

projects = [project1]

# Catkin_ws may include multiple packages
def catkin_ws_steps(job_name, repo, arch, oscode, distro):
    f = BuildFactory()
    # Remove the build directory.
    f.addStep(
        RemoveDirectory(
            name = job_name+'-clean',
            dir = Interpolate('%(prop:builddir)s'),
        )
    )
    # Check out the repository master branch, since releases are tagged and not branched
    f.addStep(
        Git(
            repourl = repo["url"],
            branch = repo["branch"],
            alwaysUseLatest = True, # this avoids broken builds when schedulers send wrong tag/rev
            mode = 'full' # clean out old versions
        )
    )

    # Build all packages in catkin_ws
    # If one package built failed, then failed
    f.addStep(
        ShellCommand(
            haltOnFailure = True,
            name = job_name+'-buildbinary',
            # Current workdir is the git source dir
            command = ['bloom-local-deb'],
            descriptionDone = ['binarydeb', job_name],
        )
    )
    return f

def catkin_ws_debbuild(c, machines, repo, arch, oscode, distro):
    # unique builder name = unique workdir
    job_name = repo["url"] + repo["branch"] + arch + oscode + distro
    print job_name

    # Add to builders
    c['builders'].append(
        BuilderConfig(
            name = job_name,
            workernames = machines,
            factory = catkin_ws_steps(job_name, repo, arch, oscode, distro),
        )
    )
    # return name of builder created
    return job_name

# create builder for each repo in every project
def builders_all_projects(c, workers):
    for project in projects:
        project_name = project["name"]
        for repo in project["repos"]:
            builder = catkin_ws_debbuild(c,
                        workers, repo,
                        project["arch"], project["oscode"], project["distro"])
            project["builders"].append(builder)

# each scheduler listen on each source, then trigger needed rebuild
def schedulers_all_projects(c):
    for project in projects:
        project_name = project["name"]
        for i, repo in enumerate(project["repos"]):
            url = repo["url"]
            branch = repo["branch"]
            builder = project["builders"][i]
            scheduler = schedulers.SingleBranchScheduler(
                            name=builder,
                            # source change hasn't project information
                            change_filter=util.ChangeFilter(repository=url,
                                branch=branch),
                            treeStableTimer=None,
                            builderNames=[builder])
            c['schedulers'].append(scheduler)

# listen on these source change events: trigger scheduler
def change_source_projects(c):
    for project in projects:
        project_name = project["name"]
        for i, repo in enumerate(project["repos"]):
            url = repo["url"]
            branch = repo["branch"]
            builder = project["builders"][i]
            c['change_source'].append(changes.GitPoller(
                    url,
                    # not the builders workdir
                    workdir='gitpoller-workdir', branch=branch,
                    pollinterval=60))


#!groovy
/*
	Jenkins build script.


	Parameters that can be set in jenkins parameter section

		Name		Type		Value
		¯¯¯¯		¯¯¯¯		¯¯¯¯¯
		gitrepo		string
		gitbranch	string

		build_type	string		NIGHTLY
						LAUNDRY
						ALPHA
						BETA
						RC
						RELEASE
						CUSTOMER


		Clean_Method:	choice.		deleteDir	// "rm -rf ." before git clone
						DistClean	// currently a noop
						SemiClean	// do one make clean before build loop starts. useful for Laundry
						Clean		// this is doing a make clean before the make of every board.
						NoClean


		Parallel_build			bolean
		brcm_force_single_thread	bolean		// set option to build the broadcom bcmkernel using only one thread.

		Verbose_build		bolean
		Verbose_download	bolean

		store_rootfs	bolean				// if this is set also store the rootfs as a tar file.

		execute_on_node	string	def	"build_default" // This is the jenkins node names to execute on.

		customer	string	def	""

		LicenseReport			bolean
		CVEReport   boolean
		OpenSDKTarballs			bolean

		email		string	def	"dev@iopsys.eu"
		email_success	boolean def	false		// If true an email will be sent on success to $email


         Boards:
		smarthub3

		disc

		eagle

		panther

		panda

		tiger

		xug534

		dg400prime
		eg400
		dg400

		ex400

		easy350
		norrland
		easy550
		speedport_smart3

*/

/*
   OBS!!!! order is important.

   Boards of a specific architecure HAVE TO be in sequence.

   Try to sort the board list so that boards sharing the same broadcom profile number
   is in sequence to avoid recompile of bcmkernel package

*/

broadcom_boards = [
		"smarthub3",
		"disc",
		"eagle",
		"panda",
		"panther",
		"tiger",
		"xug534",
		"dg400prime","eg400","dg400","f104w"
]

mediatek_boards = [ "ex400" ]

intel_boards = [ "easy350", "norrland", "easy550", "speedport_smart3" ]

def all_boards = broadcom_boards + mediatek_boards + intel_boards

/* boards to build */
def boards = get_enabled(all_boards)

echo "enabled boards is $boards"

/********************************************************************************/
/*                                 sanity check input parameters		*/
/********************************************************************************/

/* Sanity check on mandatory parameters, to fail fast */
def params_check = [ "gitrepo", "gitbranch", "build_type" ]
for (String param_check : params_check) {

	if (params["$param_check"] == null || params["$param_check"] == ""){
		error "Pararameter \"$param_check\" needs to be set";
	}else{
		def res=params["$param_check"];
		echo "Parameter $param_check set to [${res}]"
	}
}

/* make sure that no release/alpha/beta/rc/ is built with a tag containing the wrong name */

switch (build_type) {
	case ["ALPHA", "BETA", "RC"]:
		if ( !(gitbranch.contains(build_type)) )
			error "Invalid git branch [$gitbranch]. Only tags containing $build_type is allowed"
		break;
	case "RELEASE":
		if ( !( gitbranch ==~ /^\d+\.\d+\.\d+[A-Z]?$/ ) )
			error "Invalid git branch [$gitbranch]. RELEASE must be built from tag on the form Major.Minor.Maintenance release"
		break;
	default:
		echo "No validation done for build_type $build_type"
		break;
}

/* Set default value for email and customer if not set */
if (params.email == null)
	email = "dev@iopsys.eu";

echo "On error an email will be sent to [${email}]"

if (params.customer == null)
	customer = "";

echo "Parameter customer set to [${customer}]"

/* Make sure that bolean parameters are actually bolean and not strings */
/* variables to check: Parallel_build, Verbose_build, Verbose_download, store_rootfs, RunTests */
/* The variables needs to have a proper value if it's not set from jenkins or set to wrong type */
/* is there a better way to do this ? less code using eval type of function over a list ?? */
if (params.Parallel_build == null){
	Parallel_build = false;
}else {
	if (params.Parallel_build){
		Parallel_build = true;
	}
	else {
		Parallel_build = false;
	}
}
echo "Parameter Parallel_build set to [${Parallel_build}]"

if (params.Verbose_build == null){
	Verbose_build = false;
}else{
	if (params.Verbose_build){
		Verbose_build = true;
	}
	else {
		Verbose_build = false;
	}
}
echo "Parameter Verbose set to [${Verbose_build}]"

if (params.Verbose_download == null){
	Verbose_download = false;
}else{
	if (params.Verbose_download){
		Verbose_download = true;
	}
	else {
		Verbose_download = false;
	}
}
echo "Parameter Verbose_download set to [${Verbose_download}]"

if (params.store_rootfs == null){
	store_rootfs = false;
}else{
	if (params.store_rootfs){
		store_rootfs = true;
	}
	else {
		store_rootfs = false;
	}
}
echo "Parameter store_rootfs set to [${store_rootfs}]"

if (params.brcm_force_single_thread == null){
	brcm_force_single_thread = false;
}else{
	if (params.brcm_force_single_thread){
		brcm_force_single_thread = true;
	}
	else {
		brcm_force_single_thread = false;
	}
}
echo "Parameter brcm_force_single_thread set to [${brcm_force_single_thread}]"

if (params.RunTests == null){
	RunTests = false;
}else{
	if (params.RunTests){
		RunTests = true;
	}
	else {
		RunTests = false;
	}
}
echo "Parameter RunTests set to [${RunTests}]"



if (params.execute_on_node == null){
	execute_on_node = 'build_default';
}
echo "Parameter execute_on_node set to [${execute_on_node}]"

//node('buildserver_17'){
node(execute_on_node){
        def access_level=""
        def iopsys_version=""

	// find out how many parallel jobs to run on node.
	// For now just read out how many cpus the node has

	if (Parallel_build) {
		echo "parallel"
		node_cpus = sh(script: "nproc", returnStdout : true).trim() as Integer
	}else{
		node_cpus = 1
		echo "single thread"
	}

	echo "The build will be using ${node_cpus} parallel jobs"

	// Do all the stuff in stages.
	try{
		ansiColor('xterm'){
			our_stages(boards)
		}

		// Email on success
		if (params.email_success != null && params.email_success) {
			mail (subject: "Jenkins build ${env.JOB_NAME} #${env.BUILD_NUMBER} Done",
			body: "Build URL: ${env.BUILD_URL}.\n\n",
			to: "${email}"
			)
		}

	} catch(error){
		echo "Got error"

		mail (subject: "Jenkins build ${env.JOB_NAME} #${env.BUILD_NUMBER} failed",
		      body: "Build URL: ${env.BUILD_URL}.\n\n",
		      to :"${email}"
					)
		      //to :"dev@iopsys.eu"


		throw error
	}finally {
	}
}

/********************************************************************************/
/*                                 helper functions                             */
/********************************************************************************/


/****************************************/
/* Build all the boards                 */
/****************************************/

def our_stages(boards){
	def brcm_last_profile=""
	def last_arch=""

	stage('Initial setup'){
		/* example showing color putput */
		//sh 'ls --color /'

		/* should we start with a clean workspace */
		try {
			if ( params.Clean_Method == "deleteDir" ){
				echo "Deleting working dir"
				deleteDir()
			}else
				echo "Not deleting working dir"
				if ( params.Clean_Method == "SemiClean" ){
					echo "Doing a make clean before build start"
					sh "make clean"
				}

				/* if we do not clean the working dir save the last used profile and arch */
				brcm_last_profile = sh (script: 'sed -n \'s/^CONFIG_BCM_KERNEL_PROFILE="\\(.*\\)"/\\1/p\' .config' ,returnStdout: true ).trim()
				last_arch = sh (script: 'sed -n \'s/^CONFIG_ARCH="\\(.*\\)"/\\1/p\' .config' ,returnStdout: true ).trim()
		} catch(error){}

		try {
			/* This will fail if the working directory is already a git repo */
			echo "Trying to clone ${gitrepo}"
			sh "git clone ${gitrepo} ."
		} catch(error){
			def cur_repo = sh (script: "git remote -v | awk '/fetch/{print\$2}'", returnStdout: true).trim()
			echo "Working directory was already a git repo (${cur_repo}). Presuming that it is correct"
			sh "git fetch --tags --prune"
		}
		echo "checking out git branch or tag (${gitbranch}) in detached HEAD state"
		sh "git checkout \$(git rev-parse ${gitbranch})"

	}

	stage ('Bootstrap') {
		echo "bootstrap"
		sh './iop bootstrap'
	}

	stage ('Feeds') {
		echo "feeds"
		sh './iop feeds_update'
	}

	for (String board : boards) {

		stage (" ${board} genconfig") {
			echo "genconfig ${board} ${customer}"
			if ( brcm_force_single_thread ){
				sh "./iop genconfig -S -c ${board} ${customer}"
			}else{
				sh "./iop genconfig -c ${board} ${customer}"
			}
		}

		/*
		  clean the  bcmkernel package, if there is no bcmkernel package just ignore the error.
		*/
		echo "Doing bcmkernel clean"
		try {sh 'make package/feeds/broadcom/bcmkernel/clean' } catch (error){}

		/*
		  clean the endptmngr package, if there is no endptmngr package just ignore the error.
		*/
		echo "Doing endptmngr clean"
		try {sh 'make package/feeds/iopsys/endptmngr/clean' } catch (error){}

		/*
		  clean the asterisk package, if there is no asterisk package just ignore the error.
		*/
		echo "Doing asterisk clean"
		try {sh 'make package/feeds/openwrt_telephony/asterisk/clean' } catch (error){}

		if ( [ "RELEASE" ].contains(build_type)){
		echo "Doing bin clean so that Licences reports can be generated "
		sh 'rm -rf ./bin/*'
		}
		stage (" ${board} Download") {
			echo "make download"

			if ( Verbose_download ){ extra="V=s"}else{extra=""}

			try {
				/* for some reason the parallel version do not report error on failure */
				/* so untill that actually work just do one file at a time.            */
				/* about half the speed for download step                              */
//				sh "make -j $node_cpus $extra download"
				sh "make  $extra download"
			}
			catch(error){
				echo "Got error during Download. Redo make download one more time"
				sh "make download V=s"
			}
		}

		stage ("${board} Tools") {
			echo "make tools"
			sh "make -j $node_cpus tools/install"
		}

		stage ("${board} Toolchain") {
			echo "make toolchain"
			sh "make -j $node_cpus toolchain/install"
		}

		stage ("${board} Build") {
			echo "make "

			if ( params.Clean_Method == "Clean" ){
				echo "Doing a make clean"
				sh "make clean"
			}

			try {
				if ( Verbose_build ){
					sh "make -j$node_cpus V=s"
				}else{
					sh "make -j$node_cpus"
				}
			} /* if build fail rebuild non parallel and with verbose output */
			catch(error){
				sh 'make -j1 V=s'
			}
		}


		img_server_path = "";

		stage ("${board} Result") {
			def target = sh (script: 'sed -n \'s/^CONFIG_TARGET_BOARD="\\(.*\\)"/\\1/p\' .config', returnStdout: true ).trim()
			def subtarget = sh (script: 'sed -n \'s/^CONFIG_TARGET_SUBTARGET="\\(.*\\)"/\\1/p\' .config', returnStdout: true ).trim()

                        iopsys_version = sh (script: 'grep CONFIG_TARGET_VERSION= .config | cut -d \'=\' -f2 | tr -d \'"\' | \
				head -c 1', returnStdout: true).trim()

			access_level = sh (script: 'git remote -v | grep -q http && echo public || \
				echo private', returnStdout: true).trim()

			filename = board.toUpperCase()
			dirname =  board.toUpperCase()

			def sw_user = IOPSYS_FIRMWARE_PATH.split("@")[0]
			def sw_host = IOPSYS_FIRMWARE_PATH.split("@")[1].split(":")[0]
			def sw_path = IOPSYS_FIRMWARE_PATH.split("@")[1].split(":")[1]

			def pkg_user = IOPSYS_PACKAGES_PATH.split("@")[0]
			def pkg_host = IOPSYS_PACKAGES_PATH.split("@")[1].split(":")[0]
			def pkg_path = IOPSYS_PACKAGES_PATH.split("@")[1].split(":")[1]

			/* If a private build copy images to software repository */
			if ( access_level == "private" ) {

				echo "Create the folder for the new image(s)"

				def mkdir_path = "${sw_path}/${build_type}/IOP${iopsys_version}/${dirname}"
				if (customer != "") {
					def customers = customer.split(" ")
					def folder = customers[customers.length -1]
					mkdir_path = "${sw_path}/CUSTOMER/${folder}/${dirname}"
				}

				sh "ssh ${sw_user}@${sw_host} mkdir -p ${mkdir_path}"

				def img_upload_path = "${IOPSYS_FIRMWARE_PATH}/${build_type}/IOP${iopsys_version}/${dirname}/"

				/* Used for stage Test */
				def img_filename = sh (script: 'basename $(readlink ./bin/targets/'+target+'/'+subtarget+'/last.{pkgtb,itb,y3} | head -n1)', returnStdout: true).trim()

				img_server_path = "${IOPSYS_FIRMWARE_URL}/${build_type}/IOP${iopsys_version}/${dirname}/${img_filename}"

				if ( customer != "" ) {
					def customers = customer.split(" ")
					def folder = customers[customers.length -1]
					img_upload_path = "${IOPSYS_FIRMWARE_PATH}/CUSTOMER/${folder}/${dirname}/"
				}
				/* firmware file */
				echo "Uploading the image(s) to ${img_upload_path}"

				sh "scp ./bin/targets/${target}/${subtarget}/${img_filename} ${img_upload_path}"
				/* store filesystem tar file also */
				if (store_rootfs) {
					img_name = sh (script: "find ./bin/targets/${target}/${subtarget}/ -name '${filename}-*' -printf %f", returnStdout: true ).trim()
					sh "scp ./bin/targets/${target}/${subtarget}/*${board}-rootfs.tar.gz ${img_upload_path}/${img_name}-rootfs.tar.gz"
				}

				/* packages if type is alpha || beta || rc || release */
				if ( (customer == "" ) && (build_type == "ALPHA" || build_type == "BETA" || build_type == "RC" || build_type == "RELEASE" ) ) {

					/* $folder_name is the name of the current release (major.minor.maintenance[TYPE]) */
					def folder_name = sh (script: 'grep CONFIG_TARGET_VERSION= .config | cut -d \'=\' -f2 | tr -d \'"\'',
							returnStdout: true).trim()

					echo "Create folder to upload packages to"
					sh "ssh ${pkg_user}@${pkg_host} mkdir -p ${pkg_path}/${target}/${folder_name}/"

					echo "Upload packages"

					def package_arch = sh (
						script: 'grep CONFIG_TARGET_ARCH_PACKAGES= .config | cut -d \'=\' -f2 | tr -d \'"\'',
						returnStdout: true
					).trim()

					/* upload generic packages */
					sh "scp \$(find bin/packages/${package_arch}/ -name *.ipk) ${IOPSYS_PACKAGES_PATH}/${target}/${folder_name}/"

					/* upload target-specific packages */
					sh "scp \$(find bin/targets/${target}/ -name *.ipk) ${IOPSYS_PACKAGES_PATH}/${target}/${folder_name}/"
				}

			} else {
				/* This are for testing only it's images built from OpenSDK */

				def mkdir_path = "${sw_path}/${build_type}-OPEN/IOP${iopsys_version}/${dirname}"
				def img_upload_path = "${IOPSYS_FIRMWARE_PATH}/${build_type}-OPEN/IOP${iopsys_version}/${dirname}/"

				sh "ssh ${sw_user}@${sw_host} mkdir -p ${mkdir_path}"

				/* firmware file */
				echo "Uploading the image(s) to ${img_upload_path}"
				sh "scp ./bin/targets/${target}/generic/${filename}* ${img_upload_path}"

			}
			if (params.CVEReport)
			{
				try {
					/* This will fail if the working directory is already a git repo */
					echo "Trying to clone "
					sh "git clone git@dev.iopsys.eu:iopsys/cve-indicator.git "
					} catch(error){

						echo "directory did already exist doing a update"
						sh "git --git-dir ./cve-indicator/.git --work-tree ./cve-indicator fetch --all --tags --prune"
					}
					sh "./cve-indicator/iopsys_script/createreport.sh"
					sh "scp ./reports/indicator*.html ${sw_user}@${sw_host}:/var/www/html/iopsys/cve"
					sh "scp -r ./reports/cve-indicator-report ${sw_user}@${sw_host}:/var/www/html/iopsys/cve"

			}
				if ( (params.LicenseReport) &&  BoardLicenses.contains("${board}") ){
					/* Generate licenses report. this should only be done on relases */
						echo "Generate license report"
						sh "rm -rfv ./reports"
						sh "./iop license_report"
						sh "rm -rfv ./docs-iopsys-release-notes"
						sh "scp ./reports/license*.html ${sw_user}@${sw_host}:/var/www/html/iopsys/licensesreport"
						sh "scp -r ./reports/licenses-report ${sw_user}@${sw_host}:/var/www/html/iopsys/licensesreport/"
						if ( (params.LicenseReport) && [ "RELEASE" ].contains(build_type))
							{
								echo "pushing License report to doc repository"
								sh "git clone git@dev.iopsys.eu:docs/docs-iopsys-release-notes.git"
								sh "git --git-dir ./docs-iopsys-release-notes/.git --work-tree ./docs-iopsys-release-notes fetch --all --tags --prune"
								sh "git --git-dir ./docs-iopsys-release-notes/.git --work-tree ./docs-iopsys-release-notes pull origin ${gitbranch}"
								sh "git --git-dir ./docs-iopsys-release-notes/.git --work-tree ./docs-iopsys-release-notes checkout  -B ${gitbranch}"
								sh "cp ./reports/*.md docs-iopsys-release-notes/licenses/${target}/"
								sh "git --git-dir ./docs-iopsys-release-notes/.git --work-tree ./docs-iopsys-release-notes add licenses/${target}/*.md "
								sh "git --git-dir ./docs-iopsys-release-notes/.git --work-tree ./docs-iopsys-release-notes commit -am\"Added licenses Report to  ${target} for ${gitbranch} version \""
								sh "git --git-dir ./docs-iopsys-release-notes/.git --work-tree ./docs-iopsys-release-notes push origin ${gitbranch}"
					}
				}

			/* Generate tarballs. this should only be done on private NIGTHLY or private tag builds builds */
			if ( (params.OpenSDKTarballs) && [ "NIGHTLY", "RELEASE", "ALPHA", "BETA", "RC" ].contains(build_type)){
				if ( access_level == "private" ) {
					echo "Generating tarballs to public mirror"
					switch( board.toString() ) {
						/* mediatek board */
						case mediatek_boards:
							sh "./iop generate_tarballs -t mediatek"
							sh "make clean"
							break
						/* broadcom board */
						case broadcom_boards:
							sh "./iop generate_tarballs -t broadcom"
							sh "make  package/feeds/broadcom/bcmkernel/clean"
							break
						/* unknown board */
						default:
							echo "$board is not a valid board no tarballs are Generated"
							break
					}
				}
			}

			if ( access_level == "public" ) {
				echo "Copying tarballs to public mirror"
				/* Copy tar files to mirror but skip tar files with a git commit id. */
				sh '( cd dl; find . -type f -regextype posix-extended ! -iregex ".*[-_][0-9a-f]{40}.tar.gz" | rsync -rv --files-from=- ./ god@download.iopsys.eu:/var/www/html/iopsys/mirror/ )'
		   	}
			echo "Done"
		}

		if ( RunTests && access_level == "private" ) {
			stage ("${board} Test") {
				build(
					job: 'iopsysWrt-Test',
					propagate: false,
					wait: false,
					parameters: [
						string(name: 'BOARD_NAME_UPPERCASE', value: board.toUpperCase()),
						string(name: 'PARAM_SUT_FIRMWARE', value: img_server_path),
						string(name: 'BUILD_TYPE', value: build_type)
					]
				)
			}
		}
	}
}

/* Takes a list of boolean parameters and return the ones that is true in a new list */
/* speacial name stage_* is not checked and just copied over */
def get_enabled(all){
	def boards = [];

	for (String board : all){
		if (board.startsWith("stage_")){
			boards.add("$board")
		}

		if (params."$board"){
			boards.add("$board")
		}
	}
	return boards
}

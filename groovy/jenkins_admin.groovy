//  kill job
Jenkins.instance.getItemByFullName("uat/pipeline/sc-contract")
                .getBuildByNumber(117)
                .finish(
                        hudson.model.Result.ABORTED,
                        new java.io.IOException("Aborting build")
);

//  allow load js
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "default-src 'self'; style-src 'self' 'unsafe-inline';")

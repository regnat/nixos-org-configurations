let

  /* Helper functions. */
  
  pathInput = path: {type = "path"; path = toString path;};
  svnInput = url: {type = "svn"; url = url;};
  svnInputRev = url: rev: {type = "svn"; url = url; rev = rev;};

  makeJob = attrs: attrs // {
    jobScript = defaultJobScript;
    inputs = {
      job = pathInput ../../../release;
      #job = svnInput jobBaseline;
      nixpkgs = svnInputRev nixpkgsBaseline 11603;
    } // attrs.inputs;
  };


  /* Common variables for (almost) all jobs. */

  jobBaseline = https://svn.cs.uu.nl:12443/repos/trace/release/branches/new;

  nixpkgsBaseline = https://svn.cs.uu.nl:12443/repos/trace/nixpkgs/trunk;

  defaultJobScript = "generic-dist/build+release.sh";

  cacheDir = "/data/webserver/dist/nix-cache";
  cacheURL = http://buildfarm.st.ewi.tudelft.nl/releases/nix-cache;


  /* Common variables for Nix-related jobs. */

  makeNixJob = attrs: makeJob ({
    notifyAddresses = ["e.dolstra@tudelft.nl"];
    args = [
      attrs.jobExpr
      attrs.jobAttr
      "/data/webserver/dist/nix/${attrs.dirName}"
      "http://nixos.org/releases/${attrs.dirName}"
      cacheDir
      http://nixos.org/releases/nix-cache
    ];
  } // attrs);
    

  /* Common variables for UT project jobs. */

  utFmtDistDir = "/data/webserver/dist/ut-fmt";
  utFmtDistURL = http://buildfarm.st.ewi.tudelft.nl/releases/ut-fmt;

  strategoxtJobs =
    (import ./strategoxt/jobs.nix) {
      inherit makeJob pathInput svnInput svnInputRev;
    };

in
  strategoxtJobs // {

  /* Nix */

  nixTrunk = makeNixJob {
    dirName = "nix";
    inputs = {
      nixCheckout = svnInput https://svn.cs.uu.nl:12443/repos/trace/nix/trunk;
    };
    jobExpr = "../jobs/nix/nix.nix";
    jobAttr = "nixRelease";
  };
  
  nixNoBDBBranch = makeNixJob {
    dirName = "nix-no-bdb";
    inputs = {
      nixCheckout = svnInput https://svn.cs.uu.nl:12443/repos/trace/nix/branches/no-bdb;
    };
    jobExpr = "../jobs/nix/nix.nix";
    jobAttr = "nixRelease";
  };
  

  /* PatchELF */

  patchelfTrunk = makeNixJob {
    dirName = "patchelf";
    inputs = {
      patchelfCheckout = svnInput https://svn.cs.uu.nl:12443/repos/trace/patchelf/trunk;
    };
    jobExpr = "../jobs/nix/patchelf.nix";
    jobAttr = "patchelfRelease";
  };
  

  /* TorX */

  /*
  torxHead = makeJob {
    inputs = {
      torxHead = pathInput /tmp/torx-buildfarm.tgz;
    };
    notifyAddresses = ["e.dolstra@tudelft.nl"];
    args = ["./jobs/ut-fmt/torx.nix" "torxHeadRelease" utFmtDistDir cacheDir];
    #noRelease = true;
    disabled = true;
  };
  */

  
  /* Groove */

  /*
  grooveHead = makeJob {
    inputs = {
    };
    notifyAddresses = ["e.dolstra@tudelft.nl"];
    args = ["./jobs/ut-fmt/groove.nix" "grooveHeadRelease" utFmtDistDir cacheDir];
    #noRelease = true;
  };
  */

}

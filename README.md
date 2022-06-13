
# ICMaps - Fully scalable and dezentralized wmts server for Internet Computer

![ICMaps Logo](https://github.com/stumpigit/icmaps/blob/main/src/frontend/public/assets/img/logo_icmaps.png?raw=true)

## Overview

**Visit the live version on [https://ICMaps.org](https://icmaps.org)**

With ICMaps you create your own map server and can integrate your maps into any Web3 or Web2 application and even access them via GIS software. This means that the maps are stored decentrally. Thanks to the scalability of the internet computer, you can store as many map tiles as you like, the memory never runs out.

In order to provide your own map server, you need an Internet Computer Container and are responsible for ensuring that there are enough cycles to run the container. In return, ICMaps takes care of the installation of the software and maintenance of the container, completely free of charge. You can either create containers with the Internet Computer SDK or simply create them online via the NNS Dapp. No programming knowledge is necessary. You can find more information on the Canister page.

Once your container is connected to ICMaps, you can easily transfer tiles from existing tile servers or WMTS servers. Afterwards you can see the preview of the map under Preview and also the code how to integrate the map into your web application.

ICMaps uses Motoko for the background processes and Svelte for frontend

### Parts
ICMaps consists of different sub-projects. These subprojects can be found in the src directory.

#### WMTS Server
The WMTS server runs on canisters provided by the users. Once the WASM has been installed on a canister, layers and the associated tiles can be stored in it. The WMTS server independently organises the storage canisters and provides the tiles via HTTP requests. 

#### Frontend
The frontend is accessible at [https://ICMaps.org](https://icmaps.org) and enables the administration of the WMTS canisters and the creation and filling of layers. Existing tile servers can be mirrored for this purpose. The frontend is developed in Svelte. 

#### Backend
The backend is the storage interface for the frontend, where the user - canister relation is stored. In addition, new WMTS software versions are cached in this canister so that they can be applied to all managed canisters. 

## Getting Started

## Compiling the code and running local
For compiling the code you need a linux or mac environment or use Docker in combination with visual studio code.
First download and install the dfx sdk. According to [Internet Computer instructions](https://internetcomputer.org/docs/current/developer-docs/quickstart/local-quickstart/) you have to run:

    sh -ci "$(curl -fsSL https://smartcontracts.org/install.sh)"
Afterwards you can clone the git repository to a directory:

Now, start the local internet computer

    dfx start --background
Next we can build ICMaps

    dfx deploy --argument '(null)'

Well done, now you can start your Browser and browse to the frontend webpage. After the deploy you well see the Principal of the frontend. Or you can get it by typing:

    dfx canister id frontend

with this id you can go to page http://{principal}.localhost:8080/ and log in with a new Internet Identity. If you are logged in, click on your avatar on the top right and select "Who am I". Copy and use your Principal for making you admin to the backend:

    dfx canister update-settings backend --add-controller 4y5a6-gc2oc-4qebg-roaeu-2xxdd-3sfyo-zaawe-sbyxn-biwwj-fdbx5-qqe

(Replace the ID)

It's important that the backend is a controller of himself so we have to adjust some rights. Also for the next step, we enable the backend to write to the wmtsserver

    dfx canister update-settings backend --add-controller $(dfx canister id backend)
    dfx canister update-settings wmtsserver --add-controller $(dfx canister id backend)
    
Congratulation, you should now have your first WMTS Canister in your canisters and are ready to add layers to it. But first you have to create the initial TileMatrixSet and Layer-Structure. In the ICMaps interface click on the canister and on the button "Refresh layer tree". 

## Contributing to ICMaps
We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

### We Develop with Github
We use github to host code, to track issues and feature requests, as well as accept pull requests.

### We Use [Github Flow](https://guides.github.com/introduction/flow/index.html), So All Code Changes Happen Through Pull Requests
Pull requests are the best way to propose changes to the codebase (we use [Github Flow](https://guides.github.com/introduction/flow/index.html)). We actively welcome your pull requests:

1. Fork the repo and create your branch from `master`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

### Any contributions you make will be under the MIT Software License
In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

### Report bugs using Github's [issues](https://github.com/stumpigit/icmaps/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](); it's that easy!

### Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can. [My stackoverflow question](http://stackoverflow.com/q/12488905/180626) includes sample code that *anyone* with a base R setup can run to reproduce what I was seeing
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

People *love* thorough bug reports. I'm not even kidding.

### License
By contributing, you agree that your contributions will be licensed under its MIT License.

## Credits
- The code for the implementation of the decentralized storage of the images comes from [Motoko-CDN](https://github.com/gabrielnic/motoko-cdn) (Mini BigMap).
- For the svelte integration in IC Canister [Svelte Dapp with Motoko & Internet Identity
](https://github.com/dfinity/examples/tree/master/svelte-motoko-starter) was used. 
- The template is from [Notus Svelte](https://github.com/creativetimofficial/notus-svelte) from Creative Tim.
- The Part Contributing in this document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md) and from [BrianDK](https://gist.github.com/briandk/3d2e8b3ec8daf5a27a62)

- Many thanks to many more forum writers on forum.dfinity.com

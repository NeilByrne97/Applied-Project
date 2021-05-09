<h1 align="center">Applied Project and Minor Dissertation: 
Covid-19 Contact Tracing System Using MEAN Stack, 
Flutter Firebase Applications and NodeMCU Hardware

# Project Description
A Covid-19 Contact Tracing System to be used in the service industry andother businesses to track contact information of people in the case of a po-tential Coronavirus outbreak in the business establishment.The system is broken down into three projects. An Android Flutter Ap-plication, connected to a Firebase Firestore for CRUD interactions of theuser’s contact information and Bluetooth capabilities to send the informa-tion. A NodeMCU ESP-32 module to retrieve the information via Bluetoothand parse it through HTTP requests. A MEAN stack web application tohandle this contact information and perform CRUD operations, various fil-tering/sorting and serve as an email client.


# Repository Contents
This repository is for the purpose of the Applied Project and Minor Dissertation module GMIT. It contains:
* The full source code of the applicaiton and any relevant resoures.
* Instructions for compiling, deploying and running each part of the project.
* The dissertation in PFD and bibtex format.
* A video presentation of the architecture and the working application.



# Project Details
| **Project Title** | Contact Tracing System Using MEAN Stack, Flutter Firebase Applications and NodeMCU Hardware |
| :------------- |:-------------|
| **Course**              | BSc (Hons) in Software Development |
| **Module**              | Applied Project and Minor Dissertation |
| **Institute**           | [Galway-Mayo Institute of Technology](https://www.gmit.ie/) |
| **Student**             | [Neil Byrne](https://github.com/NeilByrne97) |
| **Project Supervisor**      | Gerard Harrison |

***

## Running The Project
The following is instructions of how to install and run each component of the project.

### Download

```bash
$ git clone https://github.com/NeilByrne97/Applied-Project
```

### Flutter Mobile App
```bash
$ cd Mobile Apps/Contact Tracer
```
- On an Android device enable [developer mode](https://developer.android.com/studio/debug/dev-options).
- Open app in Android Studio.
- Run the app on "Physical device".

The Flutter app will install onto the Android phone. From here the user can create an account or 
sign in with Google.

### NodeMCU App
```bash
$ cd ESP-32 Apps/ESP32_Bluetooth
```
- Open the app in Arduino IDE.
- Plug an ESP-32 into an open port with a data cable.
- Upload sketch.

Once the code is uploaded, the ESP-32 can be monitored from a Telnet Server or through
the Serial output if it remains plugged into the computer.

### MEAN Web App
```bash
$ cd Web Apps/CovidTracker
$ code .
```
- Run mongod wherever it is located in the computer's directory.
- In VS Code open two cmd terminals.

#### Terminal 1
```bash
$ cd contactlist/
$ node index.js
```

#### Terminal 2
```bash
$ cd contactlist/client
$ ng serve
```

The web app will run on localhost:4200 which can be opened in any browser.



## Video Presentation
[![Video Presentation](https://img.youtube.com/vi/t3jqQkUNky0/0.jpg)](https://www.youtube.com/watch?v=t3jqQkUNky0)

***



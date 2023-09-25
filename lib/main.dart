import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:phonepe_payment_sdk_example/upi_app.dart';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const MerchantApp());
}

class MerchantApp extends StatefulWidget {
  const MerchantApp({super.key});

  @override
  State<MerchantApp> createState() => MerchantScreen();
}

class MerchantScreen extends State<MerchantApp> {
  String body = "";
  String callback = "flutterDemoApp";
  String checksum = "";

  Map<String, String> headers = {};
  Map<String, String> pgHeaders = {"Content-Type": "application/json"};
  List<String> apiList = <String>['Container', 'PG'];
  List<String> environmentList = <String>['UAT', 'UAT_SIM', 'PRODUCTION'];
  String apiEndPoint = "/pg/v1/pay";
  bool enableLogs = true;
  Object? result;
  String dropdownValue = 'PG';
  String environmentValue = 'UAT_SIM';
  String appId = "CUREPOINTONLINE";
  String merchantId = "CUREPOINTONLINE";
  String packageName = "com.phonepe.simulator";

  void startTransaction() {
    String request = """{
      "merchantId": "CUREPOINTONLINE",
      "merchantTransactionId": "transaction_123",
      "merchantUserId": "technology@curepoint.in",
      "amount": 1,
      "mobileNumber": "8917564117",
      "callbackUrl": "",
      "paymentInstrument": {
        "type": "UPI_INTENT",
        "targetApp": "com.phonepe.app"
      },
      "deviceContext": {"deviceOS": "ANDROID"}
    }""";
    List<int> encodedText = utf8.encode(request);
    String base64Str = base64.encode(encodedText);

    String payLoad =
        base64Str + apiEndPoint + "1cf4fd01-2d6d-4fc3-a08b-d166f88f4c4e";
    var dataToHash = payLoad;

    var bytesToHash = utf8.encode(dataToHash);
    var sha256Digest = sha256.convert(bytesToHash);
    var payLoadFinal = sha256Digest.toString() + "###1";
    checksum = payLoadFinal;
    body = base64Str;
    print("APIENDPOINT");
    print(apiEndPoint);
    print("body");
    print(base64Str);
    print("checksum");
    print(payLoadFinal);
    dropdownValue == 'Container'
        ? startContainerTransaction()
        : startPGTransaction();
  }

  void initPhonePeSdk() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, enableLogs)
        .then((isInitialized) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $isInitialized';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void isPhonePeInstalled() {
    PhonePePaymentSdk.isPhonePeInstalled()
        .then((isPhonePeInstalled) => {
              setState(() {
                result = 'PhonePe Installed - $isPhonePeInstalled';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void isGpayInstalled() {
    PhonePePaymentSdk.isGPayAppInstalled()
        .then((isGpayInstalled) => {
              setState(() {
                result = 'GPay Installed - $isGpayInstalled';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void isPaytmInstalled() {
    PhonePePaymentSdk.isPaytmAppInstalled()
        .then((isPaytmInstalled) => {
              setState(() {
                result = 'Paytm Installed - $isPaytmInstalled';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void getPackageSignatureForAndroid() {
    if (Platform.isAndroid) {
      PhonePePaymentSdk.getPackageSignatureForAndroid()
          .then((packageSignature) => {
                setState(() {
                  result = 'getPackageSignatureForAndroid - $packageSignature';
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    }
  }

  void getInstalledUpiAppsForAndroid() {
    if (Platform.isAndroid) {
      PhonePePaymentSdk.getInstalledUpiAppsForAndroid()
          .then((apps) => {
                setState(() {
                  if (apps != null) {
                    Iterable l = json.decode(apps);
                    List<UPIApp> upiApps = List<UPIApp>.from(
                        l.map((model) => UPIApp.fromJson(model)));
                    String appString = '';
                    for (var element in upiApps) {
                      appString +=
                          "${element.applicationName} ${element.version} ${element.packageName}";
                    }
                    result = 'Installed Upi Apps - $appString';
                  } else {
                    result = 'Installed Upi Apps - 0';
                  }
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    }
  }

  void startPGTransaction() async {
    try {
      PhonePePaymentSdk.startPGTransaction(
              body, callback, checksum, pgHeaders, apiEndPoint, packageName)
          .then((response) => {
                setState(() {
                  if (response != null) {
                    String status = response['status'].toString();
                    String error = response['error'].toString();
                    if (status == 'SUCCESS') {
                      result = "Flow Completed - Status: Success!";
                    } else {
                      result =
                          "Flow Completed - Status: $status and Error: $error";
                    }
                  } else {
                    result = "Flow Incomplete";
                  }
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }

  void handleError(error) {
    setState(() {
      if (error is Exception) {
        result = error.toString();
      } else {
        result = {"error": error};
      }
    });
  }

  void startContainerTransaction() async {
    try {
      PhonePePaymentSdk.startContainerTransaction(
              body, callback, checksum, headers, apiEndPoint)
          .then((response) => {
                setState(() {
                  if (response != null) {
                    String status = response['status'].toString();
                    String error = response['error'].toString();
                    if (status == 'SUCCESS') {
                      result = "Flow Completed - Status: Success!";
                    } else {
                      result =
                          "Flow Completed - Status: $status and Error: $error";
                    }
                  } else {
                    result = "Flow Incomplete";
                  }
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      result = {"error": error};
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Merchant Demo App'),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(7),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Merchant Id',
                    ),
                    onChanged: (text) {
                      merchantId = text;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'App Id',
                    ),
                    onChanged: (text) {
                      appId = text;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Text('Select the environment'),
                      DropdownButton<String>(
                        value: environmentValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            environmentValue = value!;
                            if (environmentValue == 'PRODUCTION') {
                              packageName = "com.phonepe.app";
                            } else if (environmentValue == 'UAT') {
                              packageName = "com.phonepe.app.preprod";
                            } else if (environmentValue == 'UAT_SIM') {
                              packageName = "com.phonepe.simulator";
                            }
                          });
                        },
                        items: environmentList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  Visibility(
                      maintainSize: false,
                      maintainAnimation: false,
                      maintainState: false,
                      visible: Platform.isAndroid,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            Text("Package Name: $packageName"),
                          ])),
                  const SizedBox(height: 10),
                  // Row(
                  //   children: <Widget>[
                  //     Checkbox(
                  //         value: enableLogs,
                  //         onChanged: (state) {
                  //           setState(() {
                  //             enableLogs = state!;
                  //           });
                  //         }),
                  //     const Text("Enable Logs")
                  //   ],
                  // ),
                  const SizedBox(height: 10),
                  const Text(
                    'Warning: Init SDK is Mandatory to use all the functionalities*',
                    style: TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                      onPressed: initPhonePeSdk, child: const Text('INIT SDK')),
                  const SizedBox(width: 5.0),
                  // TextField(
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     hintText: 'body',
                  //   ),
                  //   onChanged: (text) {
                  //     body =
                  //         "ewogICJtZXJjaGFudElkIjogIkNVUkVQT0lOVE9OTElORSIsCiAgIm1lcmNoYW50VHJhbnNhY3Rpb25JZCI6ICJ0cmFuc2FjdGlvbl8xMjMiLAogICJtZXJjaGFudFVzZXJJZCI6ICJ0ZWNobm9sb2d5QGN1cmVwb2ludC5pbiIsCiAgImFtb3VudCI6IDEsCiAgIm1vYmlsZU51bWJlciI6ICI4OTE3NTY0MTE3IiwKICAiY2FsbGJhY2tVcmwiOiAiIiwKICAicGF5bWVudEluc3RydW1lbnQiOiB7CiAgICAidHlwZSI6ICJVUElfSU5URU5UIiwKICAgICJ0YXJnZXRBcHAiOiAiY29tLnBob25lcGUuYXBwIgogIH0sCiAgImRldmljZUNvbnRleHQiOiB7CiAgICAiZGV2aWNlT1MiOiAiQU5EUk9JRCIKICB9Cn0=";
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  // TextField(
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     hintText: 'checksum',
                  //   ),
                  //   onChanged: (text) {
                  //     checksum =
                  //         "1a35801846fd62da23e14049f497703008377ec0f98df32bb30cb28dda7304a5###1";
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Text('Select the transaction type'),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue = value!;
                            if (dropdownValue == 'PG') {
                              apiEndPoint = "/pg/v1/pay";
                            } else {
                              apiEndPoint = "/v4/debit";
                            }
                          });
                        },
                        items: apiList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  ElevatedButton(
                      onPressed: startTransaction,
                      child: const Text('Start Transaction')),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Expanded(
                  //           child: ElevatedButton(
                  //               onPressed: isPhonePeInstalled,
                  //               child: const Text('PhonePe App'))),
                  //       const SizedBox(width: 5.0),
                  //       Expanded(
                  //           child: ElevatedButton(
                  //               onPressed: isGpayInstalled,
                  //               child: const Text('Gpay App'))),
                  //       const SizedBox(width: 5.0),
                  //       Expanded(
                  //           child: ElevatedButton(
                  //               onPressed: isPaytmInstalled,
                  //               child: const Text('Paytm App'))),
                  //     ]),
                  // Visibility(
                  //     maintainSize: false,
                  //     maintainAnimation: false,
                  //     maintainState: false,
                  //     visible: Platform.isAndroid,
                  //     child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: <Widget>[
                  //           Expanded(
                  //               child: ElevatedButton(
                  //                   onPressed: getPackageSignatureForAndroid,
                  //                   child:
                  //                       const Text('Get Package Signature'))),
                  //           const SizedBox(width: 5.0),
                  //           Expanded(
                  //               child: ElevatedButton(
                  //                   onPressed: getInstalledUpiAppsForAndroid,
                  //                   child: const Text('Get UPI Apps'))),
                  //           const SizedBox(width: 5.0),
                  //         ])),
                  Text("Result: \n $result")
                ],
              ),
            ),
          )),
    );
  }
}

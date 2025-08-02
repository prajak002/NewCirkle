class PaymentRequest {
  final String appKey;
  final String username;
  final double amount;
  final String deviceId;
  final String deviceType;
  final String mode;
  final String externalRefNumber;
  final String? description;
  final double? amountCashBack;
  final double? amountAdditional;
  final String? customerMobileNumber;
  final String? customerEmail;
  final String? customerName;
  final String? accountLabel;
  final String? externalRefNumber2;
  final String? externalRefNumber3;
  final String? externalRefNumber4;
  final String? externalRefNumber5;
  final List<String>? externalRefNumbers;
  final Map<String, dynamic>? additionalData;
  final String? orgCode;
  final String? paymentBy;
  final String? emiType;

  PaymentRequest({
    required this.appKey,
    required this.username,
    required this.amount,
    required this.deviceId,
    required this.deviceType,
    required this.mode,
    required this.externalRefNumber,
    this.description,
    this.amountCashBack,
    this.amountAdditional,
    this.customerMobileNumber,
    this.customerEmail,
    this.customerName,
    this.accountLabel,
    this.externalRefNumber2,
    this.externalRefNumber3,
    this.externalRefNumber4,
    this.externalRefNumber5,
    this.externalRefNumbers,
    this.additionalData,
    this.orgCode,
    this.paymentBy,
    this.emiType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'appKey': appKey,
      'username': username,
      'amount': amount,
      'pushTo': {
        'deviceId': '$deviceId|$deviceType',
      },
      'mode': mode,
      'externalRefNumber': externalRefNumber,
    };

    if (description != null) json['description'] = description;
    if (amountCashBack != null) json['amountCashBack'] = amountCashBack;
    if (amountAdditional != null) json['amountAdditional'] = amountAdditional;
    if (customerMobileNumber != null) json['customerMobileNumber'] = customerMobileNumber;
    if (customerEmail != null) json['customerEmail'] = customerEmail;
    if (customerName != null) json['customerName'] = customerName;
    if (accountLabel != null) json['accountLabel'] = accountLabel;
    if (externalRefNumber2 != null) json['externalRefNumber2'] = externalRefNumber2;
    if (externalRefNumber3 != null) json['externalRefNumber3'] = externalRefNumber3;
    if (externalRefNumber4 != null) json['externalRefNumber4'] = externalRefNumber4;
    if (externalRefNumber5 != null) json['externalRefNumber5'] = externalRefNumber5;
    if (externalRefNumbers != null) json['externalRefNumbers'] = externalRefNumbers;
    if (additionalData != null) json['additionalData'] = additionalData;
    if (orgCode != null) json['orgCode'] = orgCode;
    if (paymentBy != null) json['paymentBy'] = paymentBy;
    if (emiType != null) json['emiType'] = emiType;

    return json;
  }

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      appKey: json['appKey'],
      username: json['username'],
      amount: (json['amount'] as num).toDouble(),
      deviceId: json['pushTo']['deviceId'].split('|')[0],
      deviceType: json['pushTo']['deviceId'].split('|')[1],
      mode: json['mode'],
      externalRefNumber: json['externalRefNumber'],
      description: json['description'],
      amountCashBack: json['amountCashBack']?.toDouble(),
      amountAdditional: json['amountAdditional']?.toDouble(),
      customerMobileNumber: json['customerMobileNumber'],
      customerEmail: json['customerEmail'],
      customerName: json['customerName'],
      accountLabel: json['accountLabel'],
      externalRefNumber2: json['externalRefNumber2'],
      externalRefNumber3: json['externalRefNumber3'],
      externalRefNumber4: json['externalRefNumber4'],
      externalRefNumber5: json['externalRefNumber5'],
      externalRefNumbers: json['externalRefNumbers']?.cast<String>(),
      additionalData: json['additionalData'],
      orgCode: json['orgCode'],
      paymentBy: json['paymentBy'],
      emiType: json['emiType'],
    );
  }
}

class PaymentResponse {
  final bool success;
  final String? messageCode;
  final String? message;
  final String? errorCode;
  final String? errorMessage;
  final String? realCode;
  final String? apiMessageTitle;
  final String? apiMessage;
  final String? apiMessageText;
  final String? apiWarning;
  final String? p2pRequestId;

  PaymentResponse({
    required this.success,
    this.messageCode,
    this.message,
    this.errorCode,
    this.errorMessage,
    this.realCode,
    this.apiMessageTitle,
    this.apiMessage,
    this.apiMessageText,
    this.apiWarning,
    this.p2pRequestId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      messageCode: json['messageCode'],
      message: json['message'],
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      realCode: json['realCode'],
      apiMessageTitle: json['apiMessageTitle'],
      apiMessage: json['apiMessage'],
      apiMessageText: json['apiMessageText'],
      apiWarning: json['apiWarning'],
      p2pRequestId: json['p2pRequestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'messageCode': messageCode,
      'message': message,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'realCode': realCode,
      'apiMessageTitle': apiMessageTitle,
      'apiMessage': apiMessage,
      'apiMessageText': apiMessageText,
      'apiWarning': apiWarning,
      'p2pRequestId': p2pRequestId,
    };
  }
}

class StatusRequest {
  final String username;
  final String appKey;
  final String origP2pRequestId;

  StatusRequest({
    required this.username,
    required this.appKey,
    required this.origP2pRequestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'appKey': appKey,
      'origP2pRequestId': origP2pRequestId,
    };
  }

  factory StatusRequest.fromJson(Map<String, dynamic> json) {
    return StatusRequest(
      username: json['username'],
      appKey: json['appKey'],
      origP2pRequestId: json['origP2pRequestId'],
    );
  }
}

class StatusResponse {
  final bool success;
  final String? messageCode;
  final String? message;
  final String? errorCode;
  final String? errorMessage;
  final String? realCode;
  final String? sessionKey;
  final String? username;
  final Map<String, dynamic>? setting;
  final List<dynamic>? apps;
  final double? amount;
  final double? amountAdditional;
  final double? amountOriginal;
  final double? amountCashBack;
  final String? authCode;
  final String? batchNumber;
  final String? cardLastFourDigit;
  final String? currencyCode;
  final String? customerName;
  final String? customerMobile;
  final String? customerReceiptUrl;
  final String? deviceSerial;
  final String? externalRefNumber;
  final String? externalRefNumber2;
  final String? externalRefNumber3;
  final String? externalRefNumber4;
  final String? externalRefNumber5;
  final List<String>? externalRefNumbers;
  final String? formattedPan;
  final String? txnId;
  final String? latitude;
  final String? longitude;
  final String? merchantName;
  final String? mid;
  final String? nonceStatus;
  final String? orgCode;
  final String? merchantCode;
  final String? payerName;
  final String? paymentCardBin;
  final String? paymentCardBrand;
  final String? paymentCardType;
  final String? pgInvoiceNumber;
  final int? postingDate;
  final String? processCode;
  final String? rrNumber;
  final String? settlementStatus;
  final String? status;
  final List<String>? states;
  final String? tid;
  final String? userMobile;
  final String? txnType;
  final bool? dccOpted;
  final int? cardHolderCurrencyExponent;
  final String? userAgreement;
  final bool? signable;
  final bool? voidable;
  final bool? refundable;
  final String? chargeSlipDate;
  final String? readableChargeSlipDate;
  final String? cardTxnTypeDesc;
  final String? issuerCode;
  final int? maximumPayAttemptsAllowed;
  final int? maximumSuccessfulPaymentAllowed;
  final bool? noExpiryFlag;
  final String? dxMode;
  final String? receiptUrl;
  final bool? signReqd;
  final String? txnTypeDesc;
  final String? acquirerCode;
  final String? additionalParamJson;
  final int? createdTime;
  final bool? customerNameAvailable;
  final bool? callbackEnabled;
  final String? accountLabel;
  final bool? onlineRefundable;
  final double? additionalAmount;
  final String? orderNumber;
  final String? reverseReferenceNumber;
  final double? totalAmount;
  final String? displayPAN;
  final String? nameOnCard;
  final String? invoiceNumber;
  final String? cardType;
  final bool? tipEnabled;
  final bool? callTC;
  final String? acquisitionId;
  final String? acquisitionKey;
  final bool? processCronOutput;
  final bool? externalDevice;
  final bool? tipAdjusted;
  final List<dynamic>? txnMetadata;
  final int? middlewareStanNumber;
  final bool? otpRequired;
  final String? p2pRequestId;
  final String? mode;
  final bool? reload;
  final bool? redirect;
  final bool? twoStepConfirmPreAuth;

  StatusResponse({
    required this.success,
    this.messageCode,
    this.message,
    this.errorCode,
    this.errorMessage,
    this.realCode,
    this.sessionKey,
    this.username,
    this.setting,
    this.apps,
    this.amount,
    this.amountAdditional,
    this.amountOriginal,
    this.amountCashBack,
    this.authCode,
    this.batchNumber,
    this.cardLastFourDigit,
    this.currencyCode,
    this.customerName,
    this.customerMobile,
    this.customerReceiptUrl,
    this.deviceSerial,
    this.externalRefNumber,
    this.externalRefNumber2,
    this.externalRefNumber3,
    this.externalRefNumber4,
    this.externalRefNumber5,
    this.externalRefNumbers,
    this.formattedPan,
    this.txnId,
    this.latitude,
    this.longitude,
    this.merchantName,
    this.mid,
    this.nonceStatus,
    this.orgCode,
    this.merchantCode,
    this.payerName,
    this.paymentCardBin,
    this.paymentCardBrand,
    this.paymentCardType,
    this.pgInvoiceNumber,
    this.postingDate,
    this.processCode,
    this.rrNumber,
    this.settlementStatus,
    this.status,
    this.states,
    this.tid,
    this.userMobile,
    this.txnType,
    this.dccOpted,
    this.cardHolderCurrencyExponent,
    this.userAgreement,
    this.signable,
    this.voidable,
    this.refundable,
    this.chargeSlipDate,
    this.readableChargeSlipDate,
    this.cardTxnTypeDesc,
    this.issuerCode,
    this.maximumPayAttemptsAllowed,
    this.maximumSuccessfulPaymentAllowed,
    this.noExpiryFlag,
    this.dxMode,
    this.receiptUrl,
    this.signReqd,
    this.txnTypeDesc,
    this.acquirerCode,
    this.additionalParamJson,
    this.createdTime,
    this.customerNameAvailable,
    this.callbackEnabled,
    this.accountLabel,
    this.onlineRefundable,
    this.additionalAmount,
    this.orderNumber,
    this.reverseReferenceNumber,
    this.totalAmount,
    this.displayPAN,
    this.nameOnCard,
    this.invoiceNumber,
    this.cardType,
    this.tipEnabled,
    this.callTC,
    this.acquisitionId,
    this.acquisitionKey,
    this.processCronOutput,
    this.externalDevice,
    this.tipAdjusted,
    this.txnMetadata,
    this.middlewareStanNumber,
    this.otpRequired,
    this.p2pRequestId,
    this.mode,
    this.reload,
    this.redirect,
    this.twoStepConfirmPreAuth,
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    return StatusResponse(
      success: json['success'] ?? false,
      messageCode: json['messageCode'],
      message: json['message'],
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      realCode: json['realCode'],
      sessionKey: json['sessionKey'],
      username: json['username'],
      setting: json['setting'],
      apps: json['apps'],
      amount: json['amount']?.toDouble(),
      amountAdditional: json['amountAdditional']?.toDouble(),
      amountOriginal: json['amountOriginal']?.toDouble(),
      amountCashBack: json['amountCashBack']?.toDouble(),
      authCode: json['authCode'],
      batchNumber: json['batchNumber'],
      cardLastFourDigit: json['cardLastFourDigit'],
      currencyCode: json['currencyCode'],
      customerName: json['customerName'],
      customerMobile: json['customerMobile'],
      customerReceiptUrl: json['customerReceiptUrl'],
      deviceSerial: json['deviceSerial'],
      externalRefNumber: json['externalRefNumber'],
      externalRefNumber2: json['externalRefNumber2'],
      externalRefNumber3: json['externalRefNumber3'],
      externalRefNumber4: json['externalRefNumber4'],
      externalRefNumber5: json['externalRefNumber5'],
      externalRefNumbers: json['externalRefNumbers']?.cast<String>(),
      formattedPan: json['formattedPan'],
      txnId: json['txnId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      merchantName: json['merchantName'],
      mid: json['mid'],
      nonceStatus: json['nonceStatus'],
      orgCode: json['orgCode'],
      merchantCode: json['merchantCode'],
      payerName: json['payerName'],
      paymentCardBin: json['paymentCardBin'],
      paymentCardBrand: json['paymentCardBrand'],
      paymentCardType: json['paymentCardType'],
      pgInvoiceNumber: json['pgInvoiceNumber'],
      postingDate: json['postingDate'],
      processCode: json['processCode'],
      rrNumber: json['rrNumber'],
      settlementStatus: json['settlementStatus'],
      status: json['status'],
      states: json['states']?.cast<String>(),
      tid: json['tid'],
      userMobile: json['userMobile'],
      txnType: json['txnType'],
      dccOpted: json['dccOpted'],
      cardHolderCurrencyExponent: json['cardHolderCurrencyExponent'],
      userAgreement: json['userAgreement'],
      signable: json['signable'],
      voidable: json['voidable'],
      refundable: json['refundable'],
      chargeSlipDate: json['chargeSlipDate'],
      readableChargeSlipDate: json['readableChargeSlipDate'],
      cardTxnTypeDesc: json['cardTxnTypeDesc'],
      issuerCode: json['issuerCode'],
      maximumPayAttemptsAllowed: json['maximumPayAttemptsAllowed'],
      maximumSuccessfulPaymentAllowed: json['maximumSuccessfulPaymentAllowed'],
      noExpiryFlag: json['noExpiryFlag'],
      dxMode: json['dxMode'],
      receiptUrl: json['receiptUrl'],
      signReqd: json['signReqd'],
      txnTypeDesc: json['txnTypeDesc'],
      acquirerCode: json['acquirerCode'],
      additionalParamJson: json['additionalParamJson'],
      createdTime: json['createdTime'],
      customerNameAvailable: json['customerNameAvailable'],
      callbackEnabled: json['callbackEnabled'],
      accountLabel: json['accountLabel'],
      onlineRefundable: json['onlineRefundable'],
      additionalAmount: json['additionalAmount']?.toDouble(),
      orderNumber: json['orderNumber'],
      reverseReferenceNumber: json['reverseReferenceNumber'],
      totalAmount: json['totalAmount']?.toDouble(),
      displayPAN: json['displayPAN'],
      nameOnCard: json['nameOnCard'],
      invoiceNumber: json['invoiceNumber'],
      cardType: json['cardType'],
      tipEnabled: json['tipEnabled'],
      callTC: json['callTC'],
      acquisitionId: json['acquisitionId'],
      acquisitionKey: json['acquisitionKey'],
      processCronOutput: json['processCronOutput'],
      externalDevice: json['externalDevice'],
      tipAdjusted: json['tipAdjusted'],
      txnMetadata: json['txnMetadata'],
      middlewareStanNumber: json['middlewareStanNumber'],
      otpRequired: json['otpRequired'],
      p2pRequestId: json['p2pRequestId'],
      mode: json['mode'],
      reload: json['reload'],
      redirect: json['redirect'],
      twoStepConfirmPreAuth: json['twoStepConfirmPreAuth'],
    );
  }
}

class CancelRequest {
  final String username;
  final String appKey;
  final String origP2pRequestId;
  final String deviceId;
  final String deviceType;

  CancelRequest({
    required this.username,
    required this.appKey,
    required this.origP2pRequestId,
    required this.deviceId,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'appKey': appKey,
      'origP2pRequestId': origP2pRequestId,
      'pushTo': {
        'deviceId': '$deviceId|$deviceType',
      },
    };
  }

  factory CancelRequest.fromJson(Map<String, dynamic> json) {
    return CancelRequest(
      username: json['username'],
      appKey: json['appKey'],
      origP2pRequestId: json['origP2pRequestId'],
      deviceId: json['pushTo']['deviceId'].split('|')[0],
      deviceType: json['pushTo']['deviceId'].split('|')[1],
    );
  }
}

class CancelResponse {
  final bool success;
  final String? messageCode;
  final String? message;
  final String? errorCode;
  final String? errorMessage;
  final String? realCode;
  final String? apiMessageTitle;
  final String? apiMessage;
  final String? apiMessageText;
  final String? apiWarning;
  final String? origP2pRequestId;

  CancelResponse({
    required this.success,
    this.messageCode,
    this.message,
    this.errorCode,
    this.errorMessage,
    this.realCode,
    this.apiMessageTitle,
    this.apiMessage,
    this.apiMessageText,
    this.apiWarning,
    this.origP2pRequestId,
  });

  factory CancelResponse.fromJson(Map<String, dynamic> json) {
    return CancelResponse(
      success: json['success'] ?? false,
      messageCode: json['messageCode'],
      message: json['message'],
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      realCode: json['realCode'],
      apiMessageTitle: json['apiMessageTitle'],
      apiMessage: json['apiMessage'],
      apiMessageText: json['apiMessageText'],
      apiWarning: json['apiWarning'],
      origP2pRequestId: json['origP2pRequestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'messageCode': messageCode,
      'message': message,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'realCode': realCode,
      'apiMessageTitle': apiMessageTitle,
      'apiMessage': apiMessage,
      'apiMessageText': apiMessageText,
      'apiWarning': apiWarning,
      'origP2pRequestId': origP2pRequestId,
    };
  }
}

import 'package:budget/struct/settings.dart';
import 'dart:convert';
import 'package:budget/database/tables.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic> currenciesJSON = {};

loadCurrencyJSON() async {
  currenciesJSON = await json.decode(
      await rootBundle.loadString('assets/static/generated/currencies.json'));
}

Future<bool> getExchangeRates({bool forceUpdate = false}) async {
  try {
    // 检查是否需要更新汇率
    if (!forceUpdate && appStateSettings["autoUpdateExchangeRates"] == false) {
      print("自动更新汇率已禁用");
      return false;
    }
    
    // 检查上次更新时间
    if (!forceUpdate && appStateSettings["lastExchangeRateUpdate"] != null) {
      DateTime lastUpdate = DateTime.parse(appStateSettings["lastExchangeRateUpdate"]);
      DateTime now = DateTime.now();
      
      // 如果距离上次更新不到24小时，则不更新
      if (now.difference(lastUpdate).inHours < 24) {
        print("距离上次更新不足24小时，跳过汇率更新");
        return true; // 返回true表示有可用的汇率数据
      }
    }
    
    // 使用fawazahmed0的exchange-api获取最新汇率
    final response = await http.get(
      Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json'),
    ).timeout(Duration(seconds: 10)); // 添加超时处理

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map<String, dynamic> rates = data['usd'];
      
      // 更新缓存的汇率数据
      Map<String, dynamic> cachedCurrencyExchange = 
          appStateSettings["cachedCurrencyExchange"] ?? {};
      
      // 更新汇率数据
      rates.forEach((currency, rate) {
        if (currency != 'date') { // 跳过日期字段
          cachedCurrencyExchange[currency.toUpperCase()] = rate;
        }
      });
      
      // 保存更新后的汇率
      await updateSettings("cachedCurrencyExchange", cachedCurrencyExchange, updateGlobalState: false);
      
      // 更新最后更新时间
      await updateSettings("lastExchangeRateUpdate", DateTime.now().toString(), updateGlobalState: false);
      
      print("汇率数据已更新");
      return true;
    } else {
      print("获取汇率失败: ${response.statusCode}");
      // 检查是否有缓存的汇率数据
      if (appStateSettings["cachedCurrencyExchange"] != null && 
          (appStateSettings["cachedCurrencyExchange"] as Map).isNotEmpty) {
        print("使用缓存的汇率数据");
        return true;
      }
      return false;
    }
  } catch (e) {
    print("获取汇率时发生错误: $e");
    // 检查是否有缓存的汇率数据
    if (appStateSettings["cachedCurrencyExchange"] != null && 
        (appStateSettings["cachedCurrencyExchange"] as Map).isNotEmpty) {
      print("使用缓存的汇率数据");
      return true;
    }
    return false;
  }
}

double amountRatioToPrimaryCurrencyGivenPk(
  AllWallets allWallets,
  String walletPk, {
  Map<String, dynamic>? appStateSettingsPassed,
}) {
  if (allWallets.indexedByPk[walletPk] == null) return 1;
  return amountRatioToPrimaryCurrency(
    allWallets,
    allWallets.indexedByPk[walletPk]?.currency,
    appStateSettingsPassed: appStateSettingsPassed,
  );
}

double amountRatioToPrimaryCurrency(
  AllWallets allWallets,
  String? walletCurrency, {
  Map<String, dynamic>? appStateSettingsPassed,
}) {
  if (walletCurrency == null) {
    return 1;
  }
  if (allWallets
          .indexedByPk[
              (appStateSettingsPassed ?? appStateSettings)["selectedWalletPk"]]
          ?.currency ==
      walletCurrency) {
    return 1;
  }
  if (allWallets.indexedByPk[
          (appStateSettingsPassed ?? appStateSettings)["selectedWalletPk"]] ==
      null) {
    return 1;
  }

  double exchangeRateFromUSDToTarget = getCurrencyExchangeRate(
    allWallets
        .indexedByPk[
            (appStateSettingsPassed ?? appStateSettings)["selectedWalletPk"]]
        ?.currency,
    appStateSettingsPassed: appStateSettingsPassed,
  );
  double exchangeRateFromCurrentToUSD = 1 /
      getCurrencyExchangeRate(
        walletCurrency,
        appStateSettingsPassed: appStateSettingsPassed,
      );
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}

double? amountRatioFromToCurrency(
    String walletCurrencyBefore, String walletCurrencyAfter) {
  double exchangeRateFromUSDToTarget =
      getCurrencyExchangeRate(walletCurrencyAfter);
  double exchangeRateFromCurrentToUSD =
      1 / getCurrencyExchangeRate(walletCurrencyBefore);
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}

// assume selected wallets currency
String getCurrencyString(AllWallets allWallets, {String? currencyKey}) {
  String? selectedWalletCurrency =
      allWallets.indexedByPk[appStateSettings["selectedWalletPk"]]?.currency;
  return currencyKey != null
      ? (currenciesJSON[currencyKey]?["Symbol"] ?? "")
      : selectedWalletCurrency == null
          ? ""
          : (currenciesJSON[selectedWalletCurrency]?["Symbol"] ?? "");
}

double getCurrencyExchangeRate(
  String? currencyKey, {
  Map<String, dynamic>? appStateSettingsPassed,
}) {
  if (currencyKey == null || currencyKey == "") return 1;
  if ((appStateSettingsPassed ?? appStateSettings)["customCurrencyAmounts"]
          ?[currencyKey] !=
      null) {
    return (appStateSettingsPassed ?? appStateSettings)["customCurrencyAmounts"]
            [currencyKey]
        .toDouble();
  } else if ((appStateSettingsPassed ??
          appStateSettings)["cachedCurrencyExchange"]?[currencyKey] !=
      null) {
    return (appStateSettingsPassed ??
            appStateSettings)["cachedCurrencyExchange"][currencyKey]
        .toDouble();
  } else {
    return 1;
  }
}

double budgetAmountToPrimaryCurrency(AllWallets allWallets, Budget budget) {
  return budget.amount *
      (amountRatioToPrimaryCurrencyGivenPk(allWallets, budget.walletFk));
}

double objectiveAmountToPrimaryCurrency(
    AllWallets allWallets, Objective objective) {
  return objective.amount *
      (amountRatioToPrimaryCurrencyGivenPk(allWallets, objective.walletFk));
}

double categoryBudgetLimitToPrimaryCurrency(
    AllWallets allWallets, CategoryBudgetLimit limit) {
  return limit.amount *
      (amountRatioToPrimaryCurrencyGivenPk(allWallets, limit.walletFk));
}

// Positive (input)
double getAmountRatioWalletTransferTo(AllWallets allWallets, String walletToPk,
    {String? enteredAmountWalletPk}) {
  return amountRatioFromToCurrency(
        allWallets
            .indexedByPk[
                enteredAmountWalletPk ?? appStateSettings["selectedWalletPk"]]!
            .currency!,
        allWallets.indexedByPk[walletToPk]!.currency!,
      ) ??
      1;
}

// Negative (output)
double getAmountRatioWalletTransferFrom(
    AllWallets allWallets, String walletFromPk,
    {String? enteredAmountWalletPk}) {
  return -1 *
      (amountRatioFromToCurrency(
            allWallets
                .indexedByPk[enteredAmountWalletPk ??
                    appStateSettings["selectedWalletPk"]]!
                .currency!,
            allWallets.indexedByPk[walletFromPk]!.currency!,
          ) ??
          1);
}

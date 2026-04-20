String currencySymbol(String? currencyCode) {
  switch ((currencyCode ?? 'USD').toUpperCase()) {
    case 'USD':
    case 'CAD':
    case 'AUD':
    case 'NZD':
    case 'SGD':
      return r'$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
    case 'CNY':
      return '¥';
    case 'INR':
      return '₹';
    case 'KRW':
      return '₩';
    case 'THB':
      return '฿';
    case 'VND':
      return '₫';
    case 'RUB':
      return '₽';
    case 'TRY':
      return '₺';
    case 'CHF':
      return 'CHF';
    default:
      return (currencyCode ?? 'USD').toUpperCase();
  }
}

String formatPrice(num amount, {String? currencyCode, int decimalDigits = 2}) {
  final normalizedCode = (currencyCode ?? 'USD').toUpperCase();
  final symbol = currencySymbol(normalizedCode);
  final normalizedAmount = amount.isFinite ? amount : 0;
  final formatted = normalizedAmount.toStringAsFixed(decimalDigits);
  final isCodeToken = symbol == normalizedCode;

  if (isCodeToken) {
    return '$normalizedCode $formatted';
  }

  return '$symbol$formatted';
}

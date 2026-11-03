import 'invalid_input_exception.dart';

double gain(double shares, double buyPrice, double currentPrice) {
  if (buyPrice <= 0) {
    throw const InvalidInputException('Le prix d\'achat doit être positif.');
  }
  return shares * (currentPrice - buyPrice);
}

double performance(double startPrice, double endPrice) {
  if (startPrice <= 0) {
    throw const InvalidInputException('Le prix de départ doit être positif.');
  }
  return endPrice / startPrice - 1;
}

double variation(double previous, double current) {
  return performance(previous, current);
}

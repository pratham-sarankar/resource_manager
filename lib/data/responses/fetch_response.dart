class FetchResponse<T>{
  final List<T> data;
  final int total;

  FetchResponse({required this.data,required this.total});
}
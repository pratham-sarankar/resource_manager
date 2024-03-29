import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resource_manager/resource_manager.dart';
import 'package:resource_manager/widgets/confirmation_dialog.dart';

class ResourceTableView<T extends Resource> extends StatelessWidget {
  const ResourceTableView({
    Key? key,
    required this.repository,
    this.title = "All Resources",
    this.onError,
    this.canAdd = true,
    this.onTap,
    this.onEdit,
    this.onAdd,
  }) : super(key: key);
  final Repository<T> repository;
  final String title;
  final bool canAdd;
  final Function(Exception)? onError;
  final Function(Resource)? onTap;
  final Future<T> Function()? onAdd;
  final Future<T> Function(T value)? onEdit;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TableController<T>>(
      id: repository.hashCode,
      init: TableController(repository, onAdd: onAdd, onEdit: onEdit),
      builder: (controller) {
        return controller.obx(
          (state) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  getHeader(controller),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(Get.context!).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }
                      ),
                      child: ListView(
                        controller: controller.verticalScrollController,
                        children: [
                          Scrollbar(
                            controller:controller.horizontalScrollController,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            thumbVisibility:true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: controller.horizontalScrollController,
                              dragStartBehavior: DragStartBehavior.down,
                              child: DataTable(
                                showCheckboxColumn: false,
                                showBottomBorder: true,
                                onSelectAll: (value) {},
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      "S. no.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  for (String data in controller.column.columns)
                                    DataColumn(
                                      label: Text(
                                        data,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                                rows: [
                                  for (int i = 0; i < controller.rows.length; i++)
                                    getDataRow(controller, controller.rows[i], i),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  getFooter(controller),
                ],
              ),
            );
          },
          onLoading: const Center(
            child: CircularProgressIndicator(),
          ),
          onEmpty: Center(
            child: canAdd
                ? TextButton(
                    onPressed: () {
                      controller.insertRow();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 5),
                        Text("Add New"),
                      ],
                    ),
                  )
                : Container(),
          ),
          onError: (error) {
            return Center(
              child: Text(error.toString()),
            );
          },
        );
      },
    );
  }

  Widget getHeader(TableController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 18, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          // IntrinsicWidth(
          //   stepWidth: Get.width * 0.15,
          //   child: Autocomplete<String>(
          //     optionsBuilder: (textEditingValue) {
          //       return ["Hello", "World"];
          //     },
          //     fieldViewBuilder: (context, textEditingController, focusNode,
          //         onFieldSubmitted) {
          //       return Container(
          //         margin: const EdgeInsets.only(left: 30),
          //         width: 150,
          //         child: CupertinoTextField(
          //           controller: textEditingController,
          //           focusNode: focusNode,
          //           onSubmitted: (value) {
          //             onFieldSubmitted();
          //           },
          //           prefix: Padding(
          //             padding: const EdgeInsets.only(left: 8),
          //             child: Icon(
          //               CupertinoIcons.search,
          //               size: 18,
          //               color: context.theme.iconTheme.color,
          //             ),
          //           ),
          //           style: GoogleFonts.poppins(
          //             fontSize: 14,
          //             fontWeight: FontWeight.w400,
          //             color: context.theme.colorScheme.secondary,
          //           ),
          //           padding: const EdgeInsets.only(
          //               top: 6, bottom: 6, left: 8, right: 10),
          //           placeholder: "Type to search...",
          //           cursorHeight: 16,
          //           placeholderStyle: GoogleFonts.poppins(
          //             fontSize: 14,
          //             fontWeight: FontWeight.w300,
          //             color: context.theme.colorScheme.tertiary,
          //           ),
          //           clearButtonMode: OverlayVisibilityMode.never,
          //           decoration: BoxDecoration(
          //             border: Border.all(
          //               color: Get.theme.outlinedButtonTheme.style!.side!
          //                   .resolve({})!.color,
          //             ),
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          const Spacer(),
          TextButton(
            child: Obx(
              () => Row(
                children: controller.isRefreshing.value
                    ? [
                        const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                            strokeWidth: 2,
                          ),
                        ),
                      ]
                    : const [
                        Icon(
                          CupertinoIcons.refresh,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text("Refresh"),
                      ],
              ),
            ),
            onPressed: () {
              controller.reload();
            },
          ),
          if (canAdd)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextButton(
                child: Row(
                  children: const [
                    Icon(
                      CupertinoIcons.add,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text("Add new"),
                  ],
                ),
                onPressed: () {
                  controller.insertRow();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget getFooter(TableController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if(controller.status.isLoadingMore) const Text("Loading More ..."),
          const Spacer(),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.arrow_back_ios, size: 14),
          // ),
          // const SizedBox(width: 20),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.arrow_forward_ios, size: 14),
          // ),
        ],
      ),
    );
  }

  DataRow getDataRow(TableController controller, ResourceRow row, int index) {
    return DataRow(
      selected: false,
      onSelectChanged: (value) {
        if (onTap != null) {
          var resource = controller.state![index];
          onTap!(resource);
        }
      },
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              (index + 1).toString(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        for (Cell cell in row.cells)
          DataCell(
            Row(
              children: [
                getCell(cell),
                for (Cell child in cell.children) getCell(child)
              ],
            ),
          ),
      ],
    );
  }

  Widget getCell(Cell cell) {
    if (cell.data == null) return Container();
    Widget result;
    if (cell.isAction) {
      result = TextButton(
        onPressed: cell.onPressed,
        child: Row(
          children: [
            Icon(
              cell.icon,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              cell.data ?? "",
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    } else if ((cell.data?.startsWith("http://") ?? false) ||
        (cell.data?.startsWith("https://") ?? false)) {
      result = CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(cell.data?.trim() ?? ""),
      );
    } else {
      result = Text(
        cell.data ?? "",
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      );
    }
    return Padding(padding: const EdgeInsets.only(right: 5), child: result);
  }
}

class TableController<T extends Resource> extends GetxController
    with StateMixin<List<T>> {
  final Repository<T> repository;
  late final ScrollController verticalScrollController;
  late final ScrollController horizontalScrollController;
  final Future<T> Function()? onAdd;
  final Future<T?> Function(T value)? onEdit;
  final Function(Exception)? onError;

  TableController(this.repository, {this.onError, this.onAdd, this.onEdit});

  late int limit;
  late int offset;
  late RxBool isRefreshing;

  @override
  void onInit() {
    super.onInit();
    limit = 15;
    offset = 0;
    isRefreshing = false.obs;
    change([], status: RxStatus.loading());
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
    verticalScrollController.addListener(loadMoreListener);
    init();
  }

  loadMoreListener(){
    if(verticalScrollController.position.pixels == verticalScrollController.position.maxScrollExtent){
      loadMore();
    }
  }

  Future loadMore()async{
    offset += limit;
    change(value,status: RxStatus.loadingMore());
    var result = await repository.fetch(limit: limit, offset: offset);
    if(result.isEmpty){
      verticalScrollController.removeListener(loadMoreListener);
    }
    change([...(value??[]),...result],status: RxStatus.success());
  }

  List<ResourceRow> get rows =>
      value?.map((e) => e.getResourceRow(this)).toList() ?? [ResourceRow.empty];

  ResourceColumn get column =>
      value?.first.getResourceColumn() ?? ResourceColumn.empty;

  void init() async {
    List<T> values = await repository.fetch(limit: limit, offset: offset);
    change(values,
        status: values.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  void insertRow({Map<String, dynamic>? initialData}) async {
    var resource = repository.empty
        .fromMap(repository.empty.toMap()..addAll(initialData ?? {}));
    try {
      T? value;
      if (onAdd != null) {
        value = await onAdd!();
      } else {
        value = await Get.dialog(ResourceDialog(resource: resource));
      }
      if (value == null) return;
      isRefreshing.value = true;
      await repository.insert(value);
      isRefreshing.value = false;
      await reload();
    } catch (e) {
      isRefreshing.value = false;
    }
  }

  void destroyRow(T value) async {
    bool sure = await Get.dialog(const ConfirmationDialog(
        message: "Are you sure you want to perform this action?"));
    if (!sure) return;
    isRefreshing.value = true;
    await repository.destroy(value);
    isRefreshing.value = false;
    await reload();
  }

  void updateRow(T value) async {
    T? updatedValue;
    if (onEdit != null) {
      updatedValue = await onEdit!(value);
    } else {
      updatedValue = await Get.dialog(ResourceDialog(resource: value));
    }
    if (updatedValue == null) return;
    isRefreshing.value = true;
    await repository.update(updatedValue);
    isRefreshing.value = false;
    await reload();
  }

  Future reload() async {
    offset = 0;
    verticalScrollController.addListener(loadMoreListener);
    isRefreshing.value = true;
    List<T> values = await repository.fetch(limit: limit, offset: offset);
    isRefreshing.value = false;
    change(values,
        status: values.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  @override
  void onClose() {
    horizontalScrollController.dispose();
    super.onClose();
  }
}

import 'package:get/get.dart';
import 'package:suliman/api/data_module_manager.dart';
import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/home/domain/models/advertisement_model.dart';
import 'package:suliman/features/home/domain/services/advertisement_service_interface.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';

class AdvertisementController extends GetxController implements GetxService {
  final AdvertisementServiceInterface advertisementServiceInterface;
  AdvertisementController({required this.advertisementServiceInterface});

  List<AdvertisementModel>? _advertisementList;
  List<AdvertisementModel>? get advertisementList => _advertisementList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Duration autoPlayDuration = const Duration(seconds: 7);

  bool autoPlay = true;

  final Map<int, List<AdvertisementModel>> _moduleAdvertisementList = {};

  void switchModule(int? moduleId) {
    if (moduleId != null && _moduleAdvertisementList.containsKey(moduleId)) {
      _advertisementList = _moduleAdvertisementList[moduleId];
    } else {
      _advertisementList = null;
    }
    _currentIndex = 0;
    update();
  }

  void clearAdvertisementList({bool clearAllModuleCache = false}) {
    _advertisementList = null;
    _currentIndex = 0;
    if (clearAllModuleCache) {
      _moduleAdvertisementList.clear();
    }
    update();
  }

  Future<void> getAdvertisementList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    int generation = DataModuleManager().nextGeneration('advertisement_module');

    List<AdvertisementModel>? responseAdvertisement;
    if(dataSource == DataSourceEnum.local) {
      responseAdvertisement = await advertisementServiceInterface.getAdvertisementList(dataSource);
      if (!DataModuleManager().isGenerationActive('advertisement_module', generation) ||
          Get.find<SplashController>().module?.id != currentModuleId) {
        return;
      }
      if (responseAdvertisement != null) {
        _advertisementList = responseAdvertisement;
        if (currentModuleId != null) {
          _moduleAdvertisementList[currentModuleId] = responseAdvertisement;
        }
      }
      update();
      getAdvertisementList(dataSource: DataSourceEnum.client);
    } else {
      responseAdvertisement = await advertisementServiceInterface.getAdvertisementList(dataSource);
      if (!DataModuleManager().isGenerationActive('advertisement_module', generation) ||
          Get.find<SplashController>().module?.id != currentModuleId) {
        return;
      }
      if (responseAdvertisement != null) {
        _advertisementList = responseAdvertisement;
        if (currentModuleId != null) {
          _moduleAdvertisementList[currentModuleId] = responseAdvertisement;
        }
      }
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void updateAutoPlayStatus({bool shouldUpdate = false, bool status = false}){
    autoPlay = status;
    if(shouldUpdate){
      update();
    }
  }

}
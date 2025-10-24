import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import '../database/local_db.dart';
import 'connectivity_service.dart';

class SyncService extends ChangeNotifier {
  final LocalDatabase _localDb = LocalDatabase();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isSyncing = false;
  String? _syncStatus; // Status message for UI
  int _pendingItemsCount = 0;

  bool get isSyncing => _isSyncing;
  String? get syncStatus => _syncStatus;
  int get pendingItemsCount => _pendingItemsCount;

  StreamSubscription? _connectivitySubscription;

  SyncService() {
    _initializeSync();
  }

  void _initializeSync() {
    // Check initial connectivity
    _connectivity.checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (isOnline) {
        if (isOnline && !_isSyncing) {
          syncPendingChanges();
        }
      },
    );

    // Check for pending items on init
    _checkPendingItems();
  }

  // ============================================
  // MAIN SYNC LOGIC
  // ============================================

  Future<void> syncPendingChanges() async {
    if (_isSyncing || _connectivity.isOffline) {
      print('⚠️ Sync skipped: isSyncing=$_isSyncing, isOnline=${_connectivity.isOnline}');
      return;
    }

    _isSyncing = true;
    _syncStatus = 'Syncing...';
    notifyListeners();

    try {
      // Get all items waiting to sync
      final syncQueue = await _localDb.getSyncQueue();

      if (syncQueue.isEmpty) {
        _syncStatus = 'All synced ✅';
        print('✅ Nothing to sync');
      } else {
        print('⏳ Syncing ${syncQueue.length} items...');

        for (final item in syncQueue) {
          try {
            // TODO: When ApiService is ready, uncomment and use actual API calls
            // await _syncQueueItem(item);

            // For now, just simulate successful sync
            await Future.delayed(const Duration(milliseconds: 100));
            await _localDb.removeSyncQueueItem(item['id'] as String);
            print('✅ Synced: ${item['table_name']} / ${item['operation']}');
          } catch (e) {
            print('❌ Sync failed for ${item['id']}: $e');
            await _localDb.incrementRetryCount(item['id'] as String, e.toString());
          }
        }
      }

      _syncStatus = 'Synced ✅';
    } catch (e) {
      _syncStatus = 'Sync error ❌';
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
      await _checkPendingItems();
      notifyListeners();
    }
  }

  // Check how many items are pending sync
  Future<void> _checkPendingItems() async {
    final queue = await _localDb.getSyncQueue();
    _pendingItemsCount = queue.length;
    notifyListeners();
  }

  // This will be called from ApiService once it's integrated
  // For now it's a placeholder
  Future<void> _syncQueueItem(Map<String, dynamic> item) async {
    final tableName = item['table_name'] as String;
    final recordId = item['record_id'] as String;
    final operation = item['operation'] as String;
    final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;

    print('📤 Syncing: $tableName / $operation / $recordId');

    // TODO: Uncomment and use these when ApiService is ready:
    // if (operation == 'INSERT') {
    //   if (tableName == 'audit_results') {
    //     await apiService.createAuditResult(data);
    //   } else if (tableName == 'website_summaries') {
    //     await apiService.createWebsiteSummary(data);
    //   }
    // } else if (operation == 'UPDATE') {
    //   // Handle updates
    // } else if (operation == 'DELETE') {
    //   // Handle deletes
    // }

    // Mark as synced in local DB
    await _localDb.markSynced(tableName, recordId);
  }

  // ============================================
  // SAVE WITH OFFLINE SUPPORT
  // ============================================

  /// Save audit result with offline support
  Future<void> saveAuditWithSync(Map<String, dynamic> auditData) async {
    final id = auditData['id'] as String;

    print('💾 Saving audit: $id (${_connectivity.isOnline ? "online" : "offline"})');

    // Always save locally first
    await _localDb.saveAuditLocal(auditData);

    // If online, also upload to Supabase
    if (_connectivity.isOnline) {
      try {
        // TODO: Uncomment when ApiService is ready:
        // await apiService.createAuditResult(auditData);

        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 200));

        await _localDb.markSynced('audit_results', id);
        print('✅ Audit synced to Supabase: $id');
      } catch (e) {
        // Failed to sync, add to queue for later
        await _localDb.addToSyncQueue('audit_results', id, 'INSERT', auditData);
        print('⚠️ Offline: Queued audit $id for later sync - $e');
      }
    } else {
      // Offline: queue for sync
      await _localDb.addToSyncQueue('audit_results', id, 'INSERT', auditData);
      print('⚠️ Offline: Saved audit $id locally, will sync when online');
    }

    await _checkPendingItems();
    notifyListeners();
  }

  /// Save website summary with offline support
  Future<void> saveSummaryWithSync(Map<String, dynamic> summaryData) async {
    final id = summaryData['id'] as String;

    print('💾 Saving summary: $id (${_connectivity.isOnline ? "online" : "offline"})');

    // Always save locally first
    await _localDb.saveSummaryLocal(summaryData);

    // If online, also upload to Supabase
    if (_connectivity.isOnline) {
      try {
        // TODO: Uncomment when ApiService is ready:
        // await apiService.createWebsiteSummary(summaryData);

        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 200));

        await _localDb.markSynced('website_summaries', id);
        print('✅ Summary synced to Supabase: $id');
      } catch (e) {
        // Failed to sync, add to queue for later
        await _localDb.addToSyncQueue('website_summaries', id, 'INSERT', summaryData);
        print('⚠️ Offline: Queued summary $id for later sync - $e');
      }
    } else {
      // Offline: queue for sync
      await _localDb.addToSyncQueue('website_summaries', id, 'INSERT', summaryData);
      print('⚠️ Offline: Saved summary $id locally, will sync when online');
    }

    await _checkPendingItems();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

# Offline Prayer Times Functionality

## Overview
The app now supports offline functionality that allows users to view prayer times even when there's no internet connection.

## How It Works

### Online Mode
- Fetches prayer times using the adhan.dart package
- Uses device location to calculate prayer times
- Automatically saves the fetched data to local storage (SharedPreferences)
- Shows live data with real-time calculations

### Offline Mode
- Automatically detects when device is offline
- Loads previously cached prayer times from local storage
- Shows cached data with appropriate offline indicators
- Cache is valid for the current day only

## Features

### 1. Automatic Connectivity Detection
- Uses `connectivity_plus` package to detect network status
- Automatically switches between online/offline modes

### 2. Local Data Storage
- Uses `SharedPreferences` to store:
  - Prayer times (all 6 prayers)
  - Location coordinates (latitude, longitude)
  - Location name
  - Last update timestamp

### 3. Cache Validation
- Cache is considered valid only for the current day
- Expired cache is ignored and fresh data is fetched when online

### 4. User Interface Indicators
- Orange status badges show when data is from cache
- Different icons for cached vs offline modes:
  - 🔄 (cached) - Data is cached but device is online
  - ☁️❌ (cloud_off) - Device is offline, showing cached data

### 5. Pull-to-Refresh
- Both home and times pages support pull-to-refresh
- Manually refresh data when connection is restored

## Code Structure

### Modified Files
- `lib/services/prayer_times_service.dart` - Enhanced with caching logic
- `lib/pages/home/location_time.dart` - Added offline indicators and refresh
- `lib/pages/times/times.dart` - Added offline indicators and refresh
- `pubspec.yaml` - Added connectivity_plus and shared_preferences dependencies

### New Files
- `lib/services/connectivity_service.dart` - Centralized connectivity checking
- `lib/utils/date_time_utils.dart` - Date/time formatting utilities

## Error Handling
- Graceful fallback to cached data when online fetch fails
- Clear error messages when no cached data is available offline
- Retry functionality for failed requests

## Usage Notes
- First app launch requires internet connection to fetch initial data
- Prayer times are recalculated fresh when online for accuracy
- Notifications continue to work with cached data
- Cache is automatically cleared and refreshed daily

## Cache Management
The service provides methods to:
- `hasCachedData()` - Check if cached data exists
- `clearCache()` - Manually clear cached data
- `getNetworkStatus()` - Get current connectivity status
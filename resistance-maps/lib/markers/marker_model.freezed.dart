// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MarkerModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MarkerModelCopyWith<MarkerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarkerModelCopyWith<$Res> {
  factory $MarkerModelCopyWith(
    MarkerModel value,
    $Res Function(MarkerModel) then,
  ) = _$MarkerModelCopyWithImpl<$Res, MarkerModel>;
  @useResult
  $Res call({String id, String title, double lat, double lng, String? iconUrl});
}

/// @nodoc
class _$MarkerModelCopyWithImpl<$Res, $Val extends MarkerModel>
    implements $MarkerModelCopyWith<$Res> {
  _$MarkerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? lat = null,
    Object? lng = null,
    Object? iconUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            iconUrl: freezed == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarkerModelImplCopyWith<$Res>
    implements $MarkerModelCopyWith<$Res> {
  factory _$$MarkerModelImplCopyWith(
    _$MarkerModelImpl value,
    $Res Function(_$MarkerModelImpl) then,
  ) = __$$MarkerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, double lat, double lng, String? iconUrl});
}

/// @nodoc
class __$$MarkerModelImplCopyWithImpl<$Res>
    extends _$MarkerModelCopyWithImpl<$Res, _$MarkerModelImpl>
    implements _$$MarkerModelImplCopyWith<$Res> {
  __$$MarkerModelImplCopyWithImpl(
    _$MarkerModelImpl _value,
    $Res Function(_$MarkerModelImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? lat = null,
    Object? lng = null,
    Object? iconUrl = freezed,
  }) {
    return _then(
      _$MarkerModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        iconUrl: freezed == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MarkerModelImpl implements _MarkerModel {
  const _$MarkerModelImpl({
    required this.id,
    required this.title,
    required this.lat,
    required this.lng,
    this.iconUrl,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final String? iconUrl;

  @override
  String toString() {
    return 'MarkerModel(id: $id, title: $title, lat: $lat, lng: $lng, iconUrl: $iconUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarkerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, lat, lng, iconUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MarkerModelImplCopyWith<_$MarkerModelImpl> get copyWith =>
      __$$MarkerModelImplCopyWithImpl<_$MarkerModelImpl>(this, _$identity);
}

abstract class _MarkerModel implements MarkerModel {
  const factory _MarkerModel({
    required final String id,
    required final String title,
    required final double lat,
    required final double lng,
    final String? iconUrl,
  }) = _$MarkerModelImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  double get lat;
  @override
  double get lng;
  @override
  String? get iconUrl;
  @override
  @JsonKey(ignore: true)
  _$$MarkerModelImplCopyWith<_$MarkerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

class AppConfig {
  const AppConfig._();

  // S3 target provided by user: s3://akshaja-insignia/daily-maintenance-evidence/
  static const String s3Bucket = 'akshaja-insignia';
  static const String s3Prefix = 'daily-maintenance-evidence';

  // Region used in default S3 public URL format.
  static const String awsRegion =
      String.fromEnvironment('AWS_REGION', defaultValue: 'ap-south-1');

  // Optional: set if using CloudFront or custom public S3 URL.
  static const String s3PublicBaseUrl =
      String.fromEnvironment('S3_PUBLIC_BASE_URL');
}

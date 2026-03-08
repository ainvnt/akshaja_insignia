class AppConfig {
  const AppConfig._();

  // S3 target provided by user: s3://akshaja-insignia/daily-maintenance-evidence/
  static const String s3Bucket = String.fromEnvironment('S3_BUCKET');
  static const String s3Prefix = String.fromEnvironment('S3_PREFIX');

  // Region used in default S3 public URL format.
  static const String awsRegion = String.fromEnvironment('AWS_REGION');

  // Optional: set if using CloudFront or custom public S3 URL.
  static const String s3PublicBaseUrl = String.fromEnvironment(
    'S3_PUBLIC_BASE_URL',
  );

  // IAM credentials passed at build time for direct S3 access.
  static const String awsAccessKeyId = String.fromEnvironment(
    'AWS_ACCESS_KEY_ID',
  );
  static const String awsSecretAccessKey = String.fromEnvironment(
    'AWS_SECRET_ACCESS_KEY',
  );
  static const String awsSessionToken = String.fromEnvironment(
    'AWS_SESSION_TOKEN',
  );

  // Safer option: backend endpoint that returns short-lived pre-signed URLs.
  static const String s3PresignApiUrl = String.fromEnvironment(
    'S3_PRESIGN_API_URL',
  );
  static const String s3PresignApiToken = String.fromEnvironment(
    'S3_PRESIGN_API_TOKEN',
  );

  static bool get hasAwsCredentials =>
      awsAccessKeyId.isNotEmpty && awsSecretAccessKey.isNotEmpty;

  static bool get hasPresignApi => s3PresignApiUrl.trim().isNotEmpty;
}

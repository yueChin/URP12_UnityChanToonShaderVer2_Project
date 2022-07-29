using System;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Serialization;
using Unity.Mathematics;


namespace UnityEngine.Rendering.Universal {
    [ExecuteAlways]
    public class ReflectionURP : MonoBehaviour {
        [Serializable]
        public enum ResolutionMulltiplier { Full, Half, Third, Quarter }

        [Serializable]
        public class PlanarReflectionSettings {
            public ResolutionMulltiplier m_ResolutionMultiplier = ResolutionMulltiplier.Third;
            public float m_ClipPlaneOffset = 0.07f;
            public LayerMask m_ReflectLayers = -1;
            public bool m_Shadows;
        }
        
        [SerializeField]
        public PlanarReflectionSettings m_settings = new PlanarReflectionSettings();
        public GameObject targetPlane;
        public float m_planeOffset;

        private static Camera _reflectionCamera;
        private RenderTexture _reflectionTexture;
        private readonly int _planarReflectionTextureId = Shader.PropertyToID("_ReflectTex");

        // public static event Action<ScriptableRenderContext, Camera> BeginPlanarReflections;
        private void OnEnable() {
            
            RenderPipelineManager.beginCameraRendering += RunPlannarReflection;  // 订阅 beginCameraRendering 事件，加入平面反射函数
        }

        private void OnDisable() {
            Cleanup();
        }

        private void OnDestroy() {
            Cleanup();
        }

        private void Cleanup() {
            RenderPipelineManager.beginCameraRendering -= RunPlannarReflection;
            if(_reflectionCamera) {  // 释放相机
                _reflectionCamera.targetTexture = null;
                SafeDestroy(_reflectionCamera.gameObject);
            }
            if (_reflectionTexture) {  // 释放纹理
                RenderTexture.ReleaseTemporary(_reflectionTexture);
            }
        }
        private static void SafeDestroy(Object obj) {
            if (Application.isEditor) {
                DestroyImmediate(obj);  //TODO
            }
            else {
                Destroy(obj);   //TODO
            }
        }
        private void RunPlannarReflection(ScriptableRenderContext context, Camera camera) {
            // we dont want to render planar reflections in reflections or previews
            if (camera.cameraType == CameraType.Reflection || camera.cameraType == CameraType.Preview)
                return;

            if (targetPlane == null) {
                targetPlane = gameObject;
            }
            if (_reflectionCamera == null) {
                _reflectionCamera = CreateReflectCamera();
            }

            PlanarReflectionSettingData data = new PlanarReflectionSettingData(); // save quality settings and lower them for the planar reflections
            data.Set(); // set quality settings

            UpdateReflectionCamera(camera);  // 设置相机位置和方向等参数
            CreatePlanarReflectionTexture(camera);  // create and assign RenderTexture

            // BeginPlanarReflections?.Invoke(context, _reflectionCamera); // callback Action for PlanarReflection "?."确保event被订阅
            UniversalRenderPipeline.RenderSingleCamera(context, _reflectionCamera); // render planar reflections  开始渲染函数

            data.Restore(); // restore the quality settings
            Shader.SetGlobalTexture(_planarReflectionTextureId, _reflectionTexture); // Assign texture to water shader
        }

        private int2 ReflectionResolution(Camera cam, float scale) {
            int x = (int)(cam.pixelWidth * scale * GetScaleValue());
            int y = (int)(cam.pixelHeight * scale * GetScaleValue());
            return new int2(x, y);
        }

        private float GetScaleValue() {
            switch(m_settings.m_ResolutionMultiplier) {
                case ResolutionMulltiplier.Full:
                    return 1f;
                case ResolutionMulltiplier.Half:
                    return 0.5f;
                case ResolutionMulltiplier.Third:
                    return 0.33f;
                case ResolutionMulltiplier.Quarter:
                    return 0.25f;
                default:
                    return 0.5f; // default to half res
            }
        }

        private void CreatePlanarReflectionTexture(Camera cam) {
            if (_reflectionTexture == null) {
                int2 res = ReflectionResolution(cam, UniversalRenderPipeline.asset.renderScale);  // 获取 RT 的大小
                const bool useHdr10 = true;
                const RenderTextureFormat hdrFormat = useHdr10 ? RenderTextureFormat.RGB111110Float : RenderTextureFormat.DefaultHDR;
                _reflectionTexture = RenderTexture.GetTemporary(res.x, res.y, 16,
                    GraphicsFormatUtility.GetGraphicsFormat(hdrFormat, true));
            }
            _reflectionCamera.targetTexture =  _reflectionTexture; // 将 RT 赋予相机
        }
        private void UpdateCamera(Camera src, Camera dest) {
            if (dest == null) return;

            // dest.CopyFrom(src);
            dest.aspect = src.aspect;
            dest.cameraType = src.cameraType;   // 这个参数不同步就错
            dest.clearFlags = src.clearFlags;
            dest.fieldOfView = src.fieldOfView;
            dest.depth = src.depth;
            dest.farClipPlane = src.farClipPlane;
            dest.focalLength = src.focalLength;
            dest.useOcclusionCulling = false;
            if (dest.gameObject.TryGetComponent(out UniversalAdditionalCameraData camData)) {  // TODO
                camData.renderShadows = m_settings.m_Shadows; // turn off shadows for the reflection camera
            }
        }

        // Calculates reflection matrix around the given plane
        private static Matrix4x4 CalculateReflectionMatrix(Vector4 plane)
        {
            Matrix4x4 reflectionMat = Matrix4x4.identity;
            reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
            reflectionMat.m01 = (-2F * plane[0] * plane[1]);
            reflectionMat.m02 = (-2F * plane[0] * plane[2]);
            reflectionMat.m03 = (-2F * plane[3] * plane[0]);

            reflectionMat.m10 = (-2F * plane[1] * plane[0]);
            reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
            reflectionMat.m12 = (-2F * plane[1] * plane[2]);
            reflectionMat.m13 = (-2F * plane[3] * plane[1]);

            reflectionMat.m20 = (-2F * plane[2] * plane[0]);
            reflectionMat.m21 = (-2F * plane[2] * plane[1]);
            reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
            reflectionMat.m23 = (-2F * plane[3] * plane[2]);

            reflectionMat.m30 = 0F;
            reflectionMat.m31 = 0F;
            reflectionMat.m32 = 0F;
            reflectionMat.m33 = 1F;

            return reflectionMat;
        }
        // Given position/normal of the plane, calculates plane in camera space.
        private Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign) {
            Vector3 offsetPos = pos + normal * m_settings.m_ClipPlaneOffset;
            Matrix4x4 m = cam.worldToCameraMatrix;
            Vector3 cameraPosition = m.MultiplyPoint(offsetPos);
            Vector3 cameraNormal = m.MultiplyVector(normal).normalized * sideSign;
            return new Vector4(cameraNormal.x, cameraNormal.y, cameraNormal.z, -Vector3.Dot(cameraPosition, cameraNormal));
        }

        private void UpdateReflectionCamera(Camera curCamera) {
            if (targetPlane == null) {
                Debug.LogError("target plane is null!");
            }

            Vector3 planeNormal = targetPlane.transform.up;
            Vector3 planePos = targetPlane.transform.position + planeNormal * m_planeOffset;

            UpdateCamera(curCamera, _reflectionCamera);  // 同步当前相机数据

            // 获取视空间平面，使用反射矩阵，将图像根据平面对称上下颠倒
            Vector4 planVS = new Vector4(planeNormal.x, planeNormal.y, planeNormal.z, -Vector3.Dot(planeNormal, planePos));
            Matrix4x4 reflectionMat = CalculateReflectionMatrix(planVS);
            _reflectionCamera.worldToCameraMatrix = curCamera.worldToCameraMatrix * reflectionMat;
            // 斜截视锥体
            Vector4 clipPlane = CameraSpacePlane(_reflectionCamera, planePos, planeNormal, 1.0f);
            Matrix4x4 newProjectionMat = CalculateObliqueMatrix(curCamera, clipPlane);
            _reflectionCamera.projectionMatrix = newProjectionMat;
            _reflectionCamera.cullingMask = m_settings.m_ReflectLayers; // never render water layer

        }
        
        // private void UpdateReflectionCamera(Camera curCamera) {
        //     // 不使用反射矩阵的方法
        //     if (targetPlane == null) {
        //         Debug.LogError("target plane is null!");
        //     }

        //     UpdateCamera(curCamera, _reflectionCamera);  // 同步当前相机数据

        //     // 将相机移转换到平面空间 plane space，再通过平面对称创建反射相机
        //     Vector3 camPosPS = targetPlane.transform.worldToLocalMatrix.MultiplyPoint(curCamera.transform.position);
        //     Vector3 reflectCamPosPS = Vector3.Scale(camPosPS, new Vector3(1, -1, 1)) + new Vector3(0, m_planeOffset, 0);  // 反射相机平面空间
        //     Vector3 reflectCamPosWS = targetPlane.transform.localToWorldMatrix.MultiplyPoint(reflectCamPosPS);  // 将反射相机转换到世界空间
        //     _reflectionCamera.transform.position = reflectCamPosWS;

        //     // 设置反射相机方向
        //     Vector3 camForwardPS = targetPlane.transform.worldToLocalMatrix.MultiplyVector(curCamera.transform.forward);
        //     Vector3 reflectCamForwardPS = Vector3.Scale(camForwardPS, new Vector3(1, -1, 1));
        //     Vector3 reflectCamForwardWS = targetPlane.transform.localToWorldMatrix.MultiplyVector(reflectCamForwardPS); 
            
        //     Vector3 camUpPS = targetPlane.transform.worldToLocalMatrix.MultiplyVector(curCamera.transform.up);
        //     Vector3 reflectCamUpPS = Vector3.Scale(camUpPS, new Vector3(-1, 1, -1));
        //     Vector3 reflectCamUpWS = targetPlane.transform.localToWorldMatrix.MultiplyVector(reflectCamUpPS); 
        //     _reflectionCamera.transform.rotation = Quaternion.LookRotation(reflectCamForwardWS, reflectCamUpWS);

        //     // 斜截视锥体
        //     Vector3 planeNormal = targetPlane.transform.up;
        //     Vector3 planePos = targetPlane.transform.position + planeNormal * m_planeOffset;
        //     var clipPlane = CameraSpacePlane(_reflectionCamera, planePos - Vector3.up * 0.1f, planeNormal, 1.0f);
        //     var newProjectionMat = CalculateObliqueMatrix(curCamera, clipPlane);
        //     _reflectionCamera.projectionMatrix = newProjectionMat;
        //     _reflectionCamera.cullingMask = m_settings.m_ReflectLayers; // never render water layer
        // }
        private Matrix4x4 CalculateObliqueMatrix(Camera cam, Vector4 plane) {
                Vector4 Q_clip = new Vector4(Mathf.Sign(plane.x), Mathf.Sign(plane.y), 1f, 1f);
                Vector4 Q_view = cam.projectionMatrix.inverse.MultiplyPoint(Q_clip);

                Vector4 scaled_plane = plane * 2.0f / Vector4.Dot(plane, Q_view);
                Vector4 M3 = scaled_plane - cam.projectionMatrix.GetRow(3);
                
                Matrix4x4 new_M = cam.projectionMatrix;
                new_M.SetRow(2, M3);

                // 使用 unity API
                // var new_M = cam.CalculateObliqueMatrix(plane);
                return new_M;
        }

        private Camera CreateReflectCamera() {
            GameObject go = new GameObject(gameObject.name + " Planar Reflection Camera",typeof(Camera));
            UniversalAdditionalCameraData cameraData = go.AddComponent(typeof(UniversalAdditionalCameraData)) as UniversalAdditionalCameraData;

            cameraData.requiresColorOption = CameraOverrideOption.Off;
            cameraData.requiresDepthOption = CameraOverrideOption.Off;
            cameraData.renderShadows = false;
            cameraData.SetRenderer(1);  // 根据 render list 的索引选择 render TODO

            Transform t = transform;
            Camera reflectionCamera = go.GetComponent<Camera>();
            reflectionCamera.transform.SetPositionAndRotation(transform.position, t.rotation);  // 相机初始位置设为当前 gameobject 位置
            reflectionCamera.depth = -10;  // 渲染优先级 [-100, 100]
            reflectionCamera.enabled = false;
            go.hideFlags = HideFlags.HideAndDontSave;

            return reflectionCamera;
        }
        
        class PlanarReflectionSettingData {
            private readonly bool _fog;
            private readonly int _maxLod;
            private readonly float _lodBias;
            private bool _invertCulling;

            public PlanarReflectionSettingData() {
                _fog = RenderSettings.fog;
                _maxLod = QualitySettings.maximumLODLevel;
                _lodBias = QualitySettings.lodBias;
            }

            public void Set() {
                _invertCulling = GL.invertCulling;
                GL.invertCulling = !_invertCulling;  // 因为镜像后绕序会反，将剔除反向
                RenderSettings.fog = false; // disable fog for now as it's incorrect with projection
                QualitySettings.maximumLODLevel = 1;
                QualitySettings.lodBias = _lodBias * 0.5f;
            }

            public void Restore() {
                GL.invertCulling = _invertCulling;
                RenderSettings.fog = _fog;
                QualitySettings.maximumLODLevel = _maxLod;
                QualitySettings.lodBias = _lodBias;
            }
        }
    }
}

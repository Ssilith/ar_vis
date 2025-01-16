using System.Collections;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Assets.Scripts
{
    public class ARCheckAvailability : MonoBehaviour
    {
        [SerializeField] ARSession arSession;

        void Start()
        {
            StartCoroutine(CheckAvailabilityCoroutine());
        }

        IEnumerator CheckAvailabilityCoroutine()
        {
            if ((ARSession.state == ARSessionState.None) ||
                (ARSession.state == ARSessionState.CheckingAvailability) ||
                (ARSession.state == ARSessionState.Installing))
            {
                yield return ARSession.CheckAvailability();
            }

            if (ARSession.state == ARSessionState.Unsupported)
            {
                SendToFlutter.Send("ar:false");
            }
            else
            {
                SendToFlutter.Send("ar:true");
                SendToFlutter.Send("info:Fallingwater to modernistyczny dom zaprojektowany w 1935 roku (a budowany w latach 1936-39) przez amerykańskiego architekta Franka Lloyda Wrighta. Dom leży nad wodospadem na potoku Bear Run rzeki Youghiogheny w stanie Pensylwania w Stanach Zjednoczonych. Fallingwater jest uważany za jedno z największych dzieł architekta, między innymi dzięki zintegrowaniu architektury z naturą oraz nietypowej bryle budynku.");
            }
        }
    }
}